;; -*- lexical-binding: t; -*-

(use-package monet
  ;; :vc (:url "https://github.com/stevemolitor/monet" :rev :newest)
  :straight (:type git :host github :repo "stevemolitor/monet")
  :config
  (setq monet-diff-cleanup-tool #'my/monet-diff-cleanup)
  ;; Ensure diff buffers display in current perspective only
  (add-to-list 'display-buffer-alist
               '("\\*Diff:.*\\*"
                 (display-buffer-reuse-window display-buffer-pop-up-window)
                 (reusable-frames . nil)
                 (inhibit-switch-frame . t)))
  ;; Add diff buffers to current perspective when created
  (defun my/monet-add-diff-to-persp (buf &rest _)
    "Add monet diff buffer to current perspective."
    (when (and (bound-and-true-p persp-mode)
               (string-match-p "\\*Diff:.*\\*" (buffer-name buf)))
      (persp-add-buffer buf)))
  (advice-add 'display-buffer :after #'my/monet-add-diff-to-persp))

(use-package claude-code
  :ensure t
  :straight (:type git :host github :repo "stevemolitor/claude-code.el" :branch "main" :depth 1 :files ("*.el" (:exclude "images/*")))
  :init
  (setq claude-code-terminal-backend 'vterm)
  (setq claude-code-display-window-fn #'display-buffer)
  ;; Force C-c TAB to override mode-specific bindings (e.g., python-mode)
  (bind-key* "C-c TAB" #'claude-code-send-command)
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
  (claude-code-kill)
  (claude-code))

(with-eval-after-load 'claude-code
  (define-key claude-code-command-map (kbd "n") #'my/claude-code-restart))

(defun my/monet-diff-cleanup (ctx)
  "Clean up diff, restoring previous buffer instead of deleting window."
  (dolist (key '(diff-buffer old-temp-buffer new-temp-buffer))
    (when-let* ((buf (alist-get key ctx))
                ((buffer-live-p buf)))
      (when (eq key 'diff-buffer)
        (when-let* ((win (get-buffer-window buf)))
          (quit-restore-window win 'bury)))
      (kill-buffer buf))))

(defun my/claude-code-switch-to-buffer (&optional arg)
  "Switch to Claude buffer in the same window."
  (interactive "P")
  (if arg
      (claude-code--switch-to-all-instances-helper)
    (if-let* ((buf (claude-code--get-or-prompt-for-buffer)))
        (switch-to-buffer buf)
      (claude-code--show-not-running-message))))

(with-eval-after-load 'claude-code
  (define-key claude-code-command-map (kbd "b") #'my/claude-code-switch-to-buffer))

(defun my/claude-simplify-region ()
  "Send region to Claude for simplification with file context."
  (interactive)
  (let* ((has-region (use-region-p))
         (ref (claude-code--format-file-reference
               nil
               (when has-region (line-number-at-pos (region-beginning) t))
               (when has-region (line-number-at-pos (region-end) t)))))
    (claude-code--do-send-command
     (concat "use code-simplifier plugin for this code" (when ref (concat "\n" ref))))))
