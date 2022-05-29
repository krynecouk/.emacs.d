(use-package eglot
  :hook ((web-mode . eglot-ensure))
  :bind (:map
	 eglot-mode-map
         ("g-R" . eglot-rename)
         ("C-c C-c" . eglot-code-actions)
         ("M-RET" . eglot-code-actions)
	 :map
	 evil-normal-state-map
	 ("g]" . flymake-goto-next-error)
	 ("g[" . flymake-goto-prev-error)
	 ("gi" . eglot-find-implementation))
  :config
  (add-to-list #'eglot-server-programs '((web-mode) "typescript-language-server" "--stdio"))
  :custom
  (eglot-autoshutdown t))
