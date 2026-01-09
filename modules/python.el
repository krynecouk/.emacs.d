;; -*- lexical-binding: t; -*-

(use-package ruff-format
  :after python
  :hook (python-mode . ruff-format-on-save-mode))

(use-package pyvenv
  :after python
  :hook ((python-mode . pyvenv-mode)
         (python-mode . pyvenv-tracking-mode)))

(use-package pytest
  :after python)

(setq byte-compile-warnings '(cl-functions))
