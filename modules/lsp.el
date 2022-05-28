(use-package eglot
  :hook ((web-mode . eglot-ensure))
  :bind (:map
	 eglot-mode-map
         ("C-c r" . eglot-rename)
         ("C-c C-d" . xref-find-definitions)
         ("C-c C-r" . xref-find-references)
         ("C-c C-c" . eglot-code-actions)
         ("M-RET" . eglot-code-actions)
	 :map
	 evil-normal-state-map
	 ("g]" . flymake-goto-next-error)
	 ("g[" . flymake-goto-prev-error))
  :custom
  (eglot-autoshutdown t))

(use-package consult-eglot)

(use-package company
  :custom
  (company-minimum-prefix-length 2))

(bind-key "C-." #'completion-at-point)
