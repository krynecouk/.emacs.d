;; -*- lexical-binding: t; -*-

(use-package eat
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  (defun eat-new ()
    (interactive)
    (let ((new-name (read-string "Enter new buffer name: ")))
      (rename-buffer new-name)
      (eat)))
  :bind (:map eat-mode-map
              ("C-c C-t" . 'eat-new)
              ("M-`" . 'persp-switch-last)
              ("M-t" . 'persp-switch))
  :hook (eat-mode . hide-line-numbers))
