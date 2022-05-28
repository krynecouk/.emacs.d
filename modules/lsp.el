(use-package eglot
  :custom
  (eglot-autoshutdown t))

(use-package consult-eglot)

(bind-key "C-." #'completion-at-point)
  
