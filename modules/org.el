;; -*- lexical-binding: t; -*-

(use-package org
  :bind
  (:map org-mode-map
	("C-c s" . #'insert-src-block))
  :config
  (setq org-indent-mode t)
  :custom
  (org-startup-indented t)
  (org-src-preserve-indentation t)
  (org-return-follows-link t)
  (org-image-actual-width nil)
  (org-startup-with-inline-images t)
  (org-src-fontify-natively t)
  (org-babel-load-languages
   '((emacs-lisp . t)))
  (org-src-tab-acts-natively t))

(defun org-insert-img-link ()
  "Inserts default img attributes and asks for img link."
  (interactive)
  (insert "#+ATTR_ORG: :width 100\n")
  (org-insert-link))

(defun insert-src-block ()
  "Inserts a src block in org mode."
  (interactive)
  (insert "#+begin_src \n\n#+end_src")
  (previous-line 2))
