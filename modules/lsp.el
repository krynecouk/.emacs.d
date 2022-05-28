(use-package eglot
  :hook ((web-mode . eglot-ensure))
  :custom
  (eglot-autoshutdown t))

(use-package consult-eglot)

(use-package company
  :custom
  (company-minimum-prefix-length 2))

(bind-key "C-." #'completion-at-point)
