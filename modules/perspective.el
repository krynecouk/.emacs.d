(use-package perspective
  :init
  (persp-mode)
  :bind (("M-t" . persp-switch)
	 ("M-]" . persp-next)
	 ("M-r" . persp-rename)
	 ("M-[" . persp-prev)
	 ("M-`" . persp-switch-last))
  :custom
  (persp-mode-prefix-key (kbd "C-x x")))

(use-package treemacs-perspective
  :after treemacs perspective
  :config (treemacs-set-scope-type 'Perspectives))
