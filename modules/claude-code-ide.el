;; -*- lexical-binding: t; -*-

;; NOTE: loads alongside claude-code.el will conflict on C-<tab>/M-RET/C-z/C-c c.
;; Import only one AI terminal module at a time in ai.el.

(defun my/claude-code-ide-plugin-dir-flags ()
  "Return --plugin-dir flags for all filevine-skills plugins."
  (let ((dir (expand-file-name "~/dev/filevine-skills/")))
    (when (file-directory-p dir)
      (cl-loop for f in (file-expand-wildcards (concat dir "*/.claude-plugin/plugin.json"))
               collect "--plugin-dir"
               collect (shell-quote-argument
                        (file-name-directory (directory-file-name (file-name-directory f))))))))

;; Defined before use-package so the C-c c binding below can reference it
(defvar my/claude-code-ide-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") #'claude-code-ide)
    (define-key map (kbd "C") #'claude-code-ide-continue)
    (define-key map (kbd "r") #'claude-code-ide-resume)
    (define-key map (kbd "k") #'claude-code-ide-stop)
    (define-key map (kbd "t") #'claude-code-ide-toggle)
    (define-key map (kbd "s") #'claude-code-ide-send-prompt)
    (define-key map (kbd "i") #'claude-code-ide-insert-at-mentioned)
    (define-key map (kbd "m") #'my/claude-code-ide-cycle-mode)
    (define-key map (kbd "?") #'claude-code-ide-menu)
    (define-key map (kbd "<escape>") #'claude-code-ide-send-escape)
    (define-key map (kbd "RET") #'my/claude-code-ide-send-return)
    (define-key map (kbd "b") #'claude-code-ide-list-sessions)
    (define-key map (kbd ">") #'my/claude-code-ide-next-buffer)
    (define-key map (kbd "<") #'my/claude-code-ide-prev-buffer)
    (define-key map (kbd "`") #'my/claude-code-ide-toggle-last-buffer)
    (define-key map (kbd "+") #'my/claude-code-ide-start-with-repos)
    map)
  "Command map for claude-code-ide, mirroring claude-code-command-map.")

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :init
  (setq claude-code-ide-terminal-backend 'vterm)
  ;; Place the window ourselves (right side, 40%), like claude-code.el
  (setq claude-code-ide-use-side-window nil)
  (add-to-list 'display-buffer-alist
               '("^\\*claude-code\\["
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'claude-code-ide-toggle)
  (bind-key "C-c c" my/claude-code-ide-command-map)
  (bind-key* "M-<RET>" #'my/claude-code-ide-send-with-context)
  (bind-key* "C-z" #'my/claude-code-ide-toggle-read-only)
  ;; Evil claims C-z (evil-toggle-key) in its state maps, which shadow bind-key*
  (with-eval-after-load 'evil
    (define-key evil-motion-state-map (kbd "C-z") nil)
    (define-key evil-insert-state-map (kbd "C-z") nil)
    (define-key evil-emacs-state-map (kbd "C-z") nil))
  :config
  ;; Extra flags are a single shell string here, not a list
  (setq claude-code-ide-cli-extra-flags
        (string-join (append '("--dangerously-skip-permissions" "--chrome")
                             (my/claude-code-ide-plugin-dir-flags))
                     " "))
  ;; Built-in MCP/IDE integration replaces monet; this adds Emacs-side tools
  (claude-code-ide-emacs-tools-setup))

(defun my/claude-code-ide-stop-close-window (orig-fn &rest args)
  "Stop Claude and close its window."
  (let ((win (cl-find-if (lambda (w) (claude-code-ide--session-buffer-p (window-buffer w)))
                         (window-list))))
    (apply orig-fn args)
    (when (and win (window-live-p win) (> (length (window-list)) 1))
      (delete-window win))))

(advice-add 'claude-code-ide-stop :around #'my/claude-code-ide-stop-close-window)

(defun my/claude-code-ide--project-buffer ()
  "Return the current project's claude session buffer, or nil."
  (get-buffer (claude-code-ide--get-buffer-name)))

(defun my/claude-code-ide-send-with-context (cmd)
  "Send CMD to Claude with current file and line context."
  (interactive "sClaude command: ")
  (let ((context (when buffer-file-name
                   (if (use-region-p)
                       (format "%s:%d-%d" buffer-file-name
                               (line-number-at-pos (region-beginning))
                               (line-number-at-pos (region-end)))
                     (format "%s:%d" buffer-file-name (line-number-at-pos))))))
    (claude-code-ide-send-prompt
     (if context (format "%s\nContext: %s" cmd context) cmd))))

(defun my/claude-code-ide-send-return ()
  "Send a return key to the current project's Claude session."
  (interactive)
  (if-let* ((buf (my/claude-code-ide--project-buffer)))
      (with-current-buffer buf
        (claude-code-ide--terminal-send-return))
    (message "No claude session for this project")))

(defun my/claude-code-ide-cycle-mode ()
  "Cycle Claude permission modes (sends Shift-Tab to the TUI)."
  (interactive)
  (if-let* ((buf (my/claude-code-ide--project-buffer)))
      (with-current-buffer buf
        (claude-code-ide--terminal-send-string "\e[Z"))
    (message "No claude session for this project")))

(defun my/claude-code-ide-toggle-read-only ()
  "Toggle vterm copy mode in the visible (or project) Claude buffer."
  (interactive)
  (if-let* ((buf (or (my/claude-code-ide--visible-buffer)
                     (my/claude-code-ide--project-buffer))))
      (with-current-buffer buf
        (vterm-copy-mode 'toggle))
    (message "No claude session")))

;; claude-code-ide allows one session per project, so unlike claude-code.el
;; these cycle across all sessions (i.e. across projects) in the side panel.
(defun my/claude-code-ide--session-buffers ()
  "Return all live claude-code-ide session buffers."
  (let (bufs)
    (maphash (lambda (dir _proc)
               (when-let* ((buf (get-buffer (funcall claude-code-ide-buffer-name-function dir))))
                 (push buf bufs)))
             claude-code-ide--processes)
    (nreverse bufs)))

(defun my/claude-code-ide--visible-buffer ()
  "Return the currently visible claude buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (claude-code-ide--session-buffer-p b) b)))
           (window-list)))

(defun my/claude-code-ide--show-buffer (buf)
  "Close any visible claude window and display BUF."
  (dolist (w (window-list))
    (when (claude-code-ide--session-buffer-p (window-buffer w))
      (delete-window w)))
  (display-buffer buf))

(defun my/claude-code-ide--cycle (offset)
  "Cycle to claude session buffer at OFFSET from the currently visible one."
  (let ((buffers (my/claude-code-ide--session-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d claude session(s)" (length buffers))
      (let* ((current (my/claude-code-ide--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/claude-code-ide--show-buffer next)))))

(defun my/claude-code-ide-next-buffer ()
  "Show the next claude session buffer in the side panel."
  (interactive)
  (my/claude-code-ide--cycle 1))

(defun my/claude-code-ide-prev-buffer ()
  "Show the previous claude session buffer in the side panel."
  (interactive)
  (my/claude-code-ide--cycle -1))

(defun my/claude-code-ide-toggle-last-buffer ()
  "Toggle between the two most relevant claude session buffers."
  (interactive)
  (let ((buffers (my/claude-code-ide--session-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d claude session(s)" (length buffers))
      (let* ((current (my/claude-code-ide--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/claude-code-ide--show-buffer other)))))

(defun my/claude-code-ide-start-with-repos ()
  "Start Claude Code with additional repos added via --add.
Prompts to select from known projects using completing-read."
  (interactive)
  (let* ((current (expand-file-name (claude-code-ide--get-working-directory)))
         (projects (cl-remove current (project-known-project-roots) :test #'string=))
         (selected (completing-read "Add repo: " projects nil t))
         (claude-code-ide-cli-extra-flags
          (concat claude-code-ide-cli-extra-flags
                  " --add " (shell-quote-argument (expand-file-name selected)))))
    (claude-code-ide)))
