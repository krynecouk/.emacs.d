(use-package python-black
  :after python
  :hook (python-mode . python-black-on-save-mode)
  :config
  (setq python-black-extra-args '("--line-length" "79")))

(use-package pyvenv
  :after python
  :hook (python-mode . pyvenv-mode))

(use-package pytest
  :after python
  :hook (python-mode . pytest-mode))
