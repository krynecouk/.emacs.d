(use-package eglot
  :hook ((web-mode . eglot-ensure))
  :bind (:map
	 eglot-mode-map
         ("M-RET" . eglot-code-actions)
	 :map
	 evil-normal-state-map
         ("g-r" . xref-find-references)
         ("g-d" . evil-goto-definition-functions)
	 ("g-i" . eglot-find-implementation)
	 ("g-]" . flymake-goto-next-error)
	 ("g-[" . flymake-goto-prev-error))
  :config
  (setq eldoc-echo-area-use-multiline-p nil)
  (add-to-list #'eglot-server-programs '((web-mode) "typescript-language-server" "--stdio"))
  :custom
  (eglot-autoshutdown t)
  (eglot-confirm-server-initiated-edits nil))
