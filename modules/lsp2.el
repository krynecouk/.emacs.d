(use-package posframe)
(use-package markdown-mode)
(use-package yasnippet)

(use-package lsp-bridge
  :straight (:host github :repo "manateelazycat/lsp-bridge" :files ("*" "acm/*"))
  :config
  (setq lsp-bridge-enable-log nil)
  (setq lsp-bridge-enable-signature-help t)
  (global-lsp-bridge-mode)
  (add-to-list 'lsp-bridge-org-babel-lang-list "emacs-lisp")
  (add-to-list 'lsp-bridge-org-babel-lang-list "sh")
  (add-to-list 'lsp-bridge-org-babel-lang-list "shell")
  (when (> (frame-pixel-width) 3000) (custom-set-faces '(corfu-default ((t (:height 1.3)))))))
