(use-package vterm
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  :hook (vterm-mode . hide-line-numbers)) ;; todo inline lambda

(use-package vterm-toggle
  :custom
  (vterm-toggle-scope 'project))
