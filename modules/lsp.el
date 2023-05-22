(use-package eglot
  :hook (
	 (web-mode . eglot-ensure)
	 (python-mode . eglot-ensure))
  :bind (:map
	 eglot-mode-map
         ("M-RET" . eglot-code-actions)
	 :map
	 evil-normal-state-map
         ("K" . eldoc-doc-buffer)
         ("gr" . xref-find-references)
         ("gd" . evil-goto-definition)
	 ("gi" . eglot-find-implementation)
	 ("g]" . flymake-goto-next-error)
	 ("g[" . flymake-goto-prev-error))
  :config
  (setq eldoc-echo-area-use-multiline-p nil)
  (add-to-list #'eglot-server-programs
	       '((web-mode) "typescript-language-server" "--stdio"))
  (add-to-list #'eglot-server-programs '(python-mode . ("pyls")))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))
