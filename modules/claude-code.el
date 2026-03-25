;; -*- lexical-binding: t; -*-

(use-package monet
  ;; :vc (:url "https://github.com/stevemolitor/monet" :rev :newest)
  :straight (:type git :host github :repo "stevemolitor/monet")
  :config
  ;; (setq monet-diff-cleanup-tool #'my/monet-diff-cleanup)
  (setq monet-diff-tool nil))

(defun my/claude-code-filevine-plugin-dirs ()
  "Return --plugin-dir flags for all filevine-skills plugins."
  (let ((dir (expand-file-name "~/dev/filevine-skills/")))
    (when (file-directory-p dir)
      (cl-loop for f in (file-expand-wildcards (concat dir "*/.claude-plugin/plugin.json"))
               collect "--plugin-dir"
               collect (file-name-directory (directory-file-name (file-name-directory f)))))))

(use-package claude-code
  :ensure t
  :straight (:type git :host github :repo "stevemolitor/claude-code.el" :branch "main" :depth 1 :files ("*.el" (:exclude "images/*")))
  :init
  (setq claude-code-terminal-backend 'vterm)
  (setq claude-code-program-switches
        (append '("--dangerously-skip-permissions")
                (my/claude-code-filevine-plugin-dirs)))
  (add-to-list 'display-buffer-alist
               '("\\*claude"
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'claude-code-toggle)
  (bind-key* "M-<RET>" #'claude-code-send-command-with-context)
  :config
  ;; optional IDE integration with Monet
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (monet-mode 1)
  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map)
  :bind (:map claude-code-command-map
              ("m" . claude-code-cycle-mode)
              ("?" . claude-code-transient)
              ("<escape>" . claude-code-send-escape)
              ("RET" . claude-code-send-return)
              ("b" . my/claude-code-switch-buffer)
              (">" . my/claude-code-next-buffer)
              ("<" . my/claude-code-prev-buffer)
              ("`" . my/claude-code-toggle-last-buffer)
              ("+" . my/claude-code-start-with-repos)))

(defun my/claude-code-auto-select (orig-fn prompt buffers &optional simple-format)
  "Skip the prompt and just pick the first buffer."
  (car buffers))

(advice-add 'claude-code--select-buffer-from-choices :around #'my/claude-code-auto-select)

(defun my/claude-code-no-cross-project (orig-fn)
  "Prevent falling back to claude buffers from other projects."
  (let* ((current-dir (claude-code--directory))
         (dir-buffers (claude-code--find-claude-buffers-for-directory current-dir)))
    (if dir-buffers
        (funcall orig-fn)
      nil)))

(advice-add 'claude-code--get-or-prompt-for-buffer :around #'my/claude-code-no-cross-project)

(defun my/claude-code-switch-buffer ()
  "Switch the claude side panel to a different project claude buffer."
  (interactive)
  (if-let* ((buffers (claude-code--find-claude-buffers-for-directory (claude-code--directory)))
            (choices (mapcar (lambda (b) (cons (claude-code--buffer-display-name b) b)) buffers))
            (selected (cdr (assoc (completing-read "Claude: " choices nil t) choices))))
      (progn
        (dolist (w (window-list))
          (when (claude-code--buffer-p (window-buffer w))
            (delete-window w)))
        (display-buffer selected))
    (message "No claude buffers for this project")))

(defun my/claude-code--visible-buffer ()
  "Return the currently visible claude buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (claude-code--buffer-p b) b)))
           (window-list)))

(defun my/claude-code--show-buffer (buf)
  "Close any visible claude window and display BUF."
  (dolist (w (window-list))
    (when (claude-code--buffer-p (window-buffer w))
      (delete-window w)))
  (display-buffer buf))

(defun my/claude-code--cycle (offset)
  "Cycle to claude buffer at OFFSET from the currently visible one."
  (let ((buffers (claude-code--find-claude-buffers-for-directory (claude-code--directory))))
    (if (< (length buffers) 2)
        (message "Only %d claude buffer(s) for this project" (length buffers))
      (let* ((current (my/claude-code--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/claude-code--show-buffer next)))))

(defun my/claude-code-next-buffer ()
  "Show the next project claude buffer in the side panel."
  (interactive)
  (my/claude-code--cycle 1))

(defun my/claude-code-prev-buffer ()
  "Show the previous project claude buffer in the side panel."
  (interactive)
  (my/claude-code--cycle -1))

(defun my/claude-code-start-with-repos ()
  "Start Claude Code with additional repos added via --add.
Prompts to select from known projects using completing-read."
  (interactive)
  (let* ((current (expand-file-name (claude-code--directory)))
         (projects (cl-remove current (project-known-project-roots) :test #'string=))
         (selected (completing-read "Add repo: " projects nil t))
         (claude-code-program-switches (append claude-code-program-switches
                                               (list "--add" (expand-file-name selected)))))
    (claude-code-new-instance)))

(defun my/claude-code-toggle-last-buffer ()
  "Toggle between current and previous project claude buffer.
Swaps to whichever buffer isn't currently visible."
  (interactive)
  (let ((buffers (claude-code--find-claude-buffers-for-directory (claude-code--directory))))
    (if (< (length buffers) 2)
        (message "Only %d claude buffer(s) for this project" (length buffers))
      (let* ((current (my/claude-code--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/claude-code--show-buffer other)))))
