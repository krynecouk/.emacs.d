;; -*- lexical-binding: t; -*-

;; OpenAI Codex integration (dgillis/emacs-codex-ide), configured to mirror
;; modules/claude-code.el. Not a terminal wrapper: sessions are JSON-RPC
;; clients of `codex app-server' rendered in normal Emacs buffers, so there
;; is no vterm backend, no raw escape/return keys, and no read-only toggle
;; (buffers are always navigable) — C-z keeps its evil binding here.
;; NOTE: import only one AI terminal module at a time in ai.el (C-<tab>,
;; M-RET and C-c c would conflict).

;; Defined before use-package so the C-c c binding below can reference it
(defvar my/codex-ide-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") #'my/codex-ide-start)
    (define-key map (kbd "C") #'codex-ide-continue)
    (define-key map (kbd "k") #'my/codex-ide-stop)
    (define-key map (kbd "t") #'my/codex-ide-toggle)
    (define-key map (kbd "s") #'codex-ide-prompt)
    (define-key map (kbd "m") #'codex-ide-agent-config-menu) ; approval/sandbox/model
    (define-key map (kbd "?") #'codex-ide-menu)
    (define-key map (kbd "<escape>") #'codex-ide-interrupt)
    (define-key map (kbd "d") #'codex-ide-session-diff-open)
    (define-key map (kbd "l") #'codex-ide-session-buffer-list)
    (define-key map (kbd "n") #'my/codex-ide-rename-buffer)
    (define-key map (kbd "b") #'my/codex-ide-switch-buffer)
    (define-key map (kbd ">") #'my/codex-ide-next-buffer)
    (define-key map (kbd "<") #'my/codex-ide-prev-buffer)
    (define-key map (kbd "`") #'my/codex-ide-toggle-last-buffer)
    map)
  "Command map for codex-ide, mirroring claude-code-command-map.")

(use-package codex-ide
  :straight (:type git :host github :repo "dgillis/emacs-codex-ide")
  :init
  ;; Equivalent of --dangerously-skip-permissions
  (setq codex-ide-approval-policy "never")
  (setq codex-ide-sandbox-mode "danger-full-access")
  ;; Emacs MCP bridge (monet equivalent) without the startup prompt
  (setq codex-ide-want-mcp-bridge t)
  ;; Let display-buffer-alist control placement: right side, 40%
  (setq codex-ide-new-session-split nil)
  (add-to-list 'display-buffer-alist
               '("^\\*codex\\["
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'my/codex-ide-toggle)
  (bind-key* "M-<RET>" #'codex-ide-prompt) ; attaches file/line context itself
  (bind-key "C-c c" my/codex-ide-command-map))

(defun my/codex-ide--project-buffers ()
  "Return live codex session buffers for the current project."
  (delq nil (mapcar #'codex-ide-session-buffer
                    (codex-ide--sessions-for-directory
                     (codex-ide--get-working-directory) t))))

(defun my/codex-ide--labeled-buffer-name (directory label)
  "Session buffer name for DIRECTORY with LABEL before the closing `*'.
Built on the package's name helpers so the prefix that
`codex-ide--session-buffer-p' matches on is preserved."
  (format "%s %s*"
          (substring (codex-ide--session-buffer-name directory) 0 -1)
          label))

(defun my/codex-ide--target-buffer ()
  "Return the visible codex buffer, or the project's first one."
  (or (my/codex-ide--visible-buffer)
      (car (my/codex-ide--project-buffers))))

(defun my/codex-ide-start ()
  "Start a codex session, prompting for a label when one already exists.
Empty input keeps the default numbered name."
  (interactive)
  (let* ((label (and (my/codex-ide--project-buffers)
                     (read-string "Buffer label: ")))
         (session (codex-ide)))
    (when-let* (session
                label
                ((not (string-empty-p label)))
                (buf (codex-ide-session-buffer session))
                ((buffer-live-p buf)))
      (with-current-buffer buf
        (rename-buffer (my/codex-ide--labeled-buffer-name
                        (codex-ide-session-directory session) label)
                       t)))))

(defun my/codex-ide--visible-buffer ()
  "Return the currently visible codex buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (codex-ide--session-buffer-p b) b)))
           (window-list)))

(defun my/codex-ide--show-buffer (buf)
  "Close any visible codex window and display BUF."
  (dolist (w (window-list))
    (when (codex-ide--session-buffer-p (window-buffer w))
      (delete-window w)))
  (display-buffer buf))

(defun my/codex-ide-toggle ()
  "Toggle the codex side panel for the current project."
  (interactive)
  (if-let* ((visible (my/codex-ide--visible-buffer)))
      (delete-window (get-buffer-window visible))
    (if-let* ((buffers (my/codex-ide--project-buffers)))
        (display-buffer (car buffers))
      (message "No codex session for this project"))))

(defun my/codex-ide-stop ()
  "Stop a codex session for this project and close its window."
  (interactive)
  (if-let* ((buf (my/codex-ide--target-buffer)))
      (let ((win (get-buffer-window buf)))
        (with-current-buffer buf
          (codex-ide-stop))
        (when (and win (window-live-p win) (> (length (window-list)) 1))
          (delete-window win)))
    (message "No codex session for this project")))

(defun my/codex-ide-rename-buffer ()
  "Rename the active codex buffer with a new label."
  (interactive)
  (if-let* ((buf (my/codex-ide--target-buffer)))
      (let ((name (my/codex-ide--labeled-buffer-name
                   (codex-ide--get-working-directory)
                   (read-string "Buffer label: "))))
        (with-current-buffer buf
          (rename-buffer name t)))
    (message "No codex session for this project")))

(defun my/codex-ide-switch-buffer ()
  "Switch the codex side panel to a different project codex buffer."
  (interactive)
  (if-let* ((buffers (my/codex-ide--project-buffers))
            (choices (mapcar (lambda (b) (cons (buffer-name b) b)) buffers))
            (selected (cdr (assoc (completing-read "Codex: " choices nil t) choices))))
      (my/codex-ide--show-buffer selected)
    (message "No codex buffers for this project")))

(defun my/codex-ide--cycle (offset)
  "Cycle to codex buffer at OFFSET from the currently visible one."
  (let ((buffers (my/codex-ide--project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d codex buffer(s) for this project" (length buffers))
      (let* ((current (my/codex-ide--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/codex-ide--show-buffer next)))))

(defun my/codex-ide-next-buffer ()
  "Show the next project codex buffer in the side panel."
  (interactive)
  (my/codex-ide--cycle 1))

(defun my/codex-ide-prev-buffer ()
  "Show the previous project codex buffer in the side panel."
  (interactive)
  (my/codex-ide--cycle -1))

(defun my/codex-ide-toggle-last-buffer ()
  "Toggle between current and previous project codex buffer."
  (interactive)
  (let ((buffers (my/codex-ide--project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d codex buffer(s) for this project" (length buffers))
      (let* ((current (my/codex-ide--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/codex-ide--show-buffer other)))))
