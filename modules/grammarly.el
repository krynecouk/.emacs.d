(use-package eglot-grammarly
  :straight (:host github :repo "emacs-grammarly/eglot-grammarly")
  :hook ((text-mode markdown-mode org-journal-mode). (lambda ()
						       (require 'eglot-grammarly)
						       (eglot-ensure))))
