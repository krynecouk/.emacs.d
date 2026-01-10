;; -*- lexical-binding: t; -*-

(use-package gptel
  :hook (gptel-mode . gptel-highlight-mode)
  :bind (("C-c RET" . gptel-send)
         ("C-c r" . gptel-rewrite)
         ("C-c ?" . gptel-menu))
  :config
  ;; (setq gptel-model 'gpt-5.1)
  (setq gptel-model 'gemini-3-flash-preview)

  (gptel-make-xai "xAI"
    :stream t
    :key #'gptel-api-key-from-auth-source)

  (gptel-make-gemini "Gemini"
    :stream t
    :key #'gptel-api-key-from-auth-source)

  (evil-define-key 'normal gptel-context-buffer-mode-map
    (kbd "q") #'gptel-context-quit
    (kbd "n") #'gptel-context-next
    (kbd "p") #'gptel-context-previous
    (kbd "d") #'gptel-context-flag-deletion
    (kbd "RET") #'gptel-context-visit))

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind (("C-c C-<tab>" . claude-code-ide-menu)
         ("C-<tab>" . claude-code-ide-toggle))
  :config
  (claude-code-ide-emacs-tools-setup))
