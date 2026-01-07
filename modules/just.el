;; -*- lexical-binding: t; -*-

(use-package just-mode
  :ensure t
  :mode (("\\.just\\'" . just-mode)
         ("\\(?:\\`\\|/\\)[Jj]ustfile\\'" . just-mode)))
