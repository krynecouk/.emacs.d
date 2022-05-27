(use-package perspective
  :init
  (persp-mode)
  :bind (("M-t" . persp-switch)
	 ("M-]" . persp-next)
	 ("M-[" . persp-prev)
	 ("M-`" . persp-switch-last))
  :custom
  (persp-mode-prefix-key (kbd "C-x x")))
