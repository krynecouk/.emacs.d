;; -*- lexical-binding: t; -*-

(use-package gptel
  :config
  (evil-define-key 'normal gptel-context-buffer-mode-map
    (kbd "q") #'gptel-context-quit
    (kbd "n") #'gptel-context-next
    (kbd "p") #'gptel-context-previous
    (kbd "d") #'gptel-context-flag-deletion
    (kbd "RET") #'gptel-context-visit))

;; Register xAI backend
(gptel-make-xai "xAI"
  :stream t
  :key #'gptel-api-key-from-auth-source)

;; Use OpenAI GPT-5.1 as default
(setq gptel-model 'gpt-5.1)

(global-set-key (kbd "C-c RET") 'gptel-send)
(global-set-key (kbd "C-c r") 'gptel-rewrite)
(global-set-key (kbd "C-c ?") 'gptel-menu)

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind (("C-c C-`" . claude-code-ide-menu)
         ("C-<tab>" . claude-code-ide-toggle))
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools
