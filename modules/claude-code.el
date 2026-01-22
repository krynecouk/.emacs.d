;; -*- lexical-binding: t; -*-

(use-package monet
  ;; :vc (:url "https://github.com/stevemolitor/monet" :rev :newest)
  :straight (:type git :host github :repo "stevemolitor/monet")
  :config
  (setq monet-diff-cleanup-tool #'my/monet-diff-cleanup)
  (setq monet-diff-tool nil))

(use-package claude-code
  :ensure t
  :straight (:type git :host github :repo "stevemolitor/claude-code.el" :branch "main" :depth 1 :files ("*.el" (:exclude "images/*")))
  :init
  (setq claude-code-terminal-backend 'vterm)
  (add-to-list 'display-buffer-alist
               '("\\*claude"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'claude-code-toggle)
  (bind-key* "M-<RET>" #'claude-code-send-command)
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
              ("RET" . claude-code-send-return)))

(defun my/claude-code-restart ()
  "Kill current Claude Code instance and start a new one."
  (interactive)
  (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t)))
    (claude-code-kill))
  (sit-for 0.1)
  (claude-code))

(defun my/claude-code-project-buffers ()
  "Return list of Claude Code buffers for current project."
  (when-let* ((root (project-root (project-current))))
    (seq-filter (lambda (buf)
                  (and (string-prefix-p "*claude" (buffer-name buf))
                       (string-match-p (regexp-quote root) (buffer-name buf))))
                (buffer-list))))

(defun my/claude-code-kill-all ()
  "Kill all Claude Code instances in the current project."
  (interactive)
  (dolist (buf (my/claude-code-project-buffers))
    (when-let* ((proc (get-buffer-process buf)))
      (set-process-query-on-exit-flag proc nil)
      (delete-process proc))
    (kill-buffer buf)))

(defun my/claude-code-toggle-around (orig-fn &rest args)
  "Toggle Claude Code, creating instance if needed without double-toggling."
  (if (my/claude-code-project-buffers)
      (apply orig-fn args)
    ;; No instance exists - just create it (which also displays it)
    (claude-code)))

(defun my/claude-code-send-command-around (orig-fn &rest args)
  "Send command to Claude Code, creating instance after collecting input if needed."
  (let ((command (read-string "Claude command: "))
        (buf (car (my/claude-code-project-buffers))))
    (unless buf
      (claude-code)
      (sit-for 0.7)
      (setq buf (car (my/claude-code-project-buffers))))
    (with-current-buffer buf
      (vterm-send-string command)
      (vterm-send-return))))

(with-eval-after-load 'claude-code
  (define-key claude-code-command-map (kbd "n") #'my/claude-code-restart)
  (define-key claude-code-command-map (kbd "K") #'my/claude-code-kill-all)
  (advice-add 'claude-code-toggle :around #'my/claude-code-toggle-around)
  (advice-add 'claude-code-send-command :around #'my/claude-code-send-command-around))
