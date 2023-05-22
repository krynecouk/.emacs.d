(use-package vterm
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  (defun vterm-new ()
    (interactive)
    (let ((new-name (read-string "Enter new buffer name: ")))
      (rename-buffer new-name)
      (vterm)))
  :bind (:map vterm-mode-map
              ("C-c C-t" . 'vterm-new)
              ("M-`" . 'persp-switch-last)
              ("M-t" . 'persp-switch))
  :hook (vterm-mode . hide-line-numbers))

(use-package vterm-toggle
  :custom
  (vterm-toggle-scope 'project))
