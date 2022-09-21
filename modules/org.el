(use-package org
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

(use-package org-journal
  :custom
  (org-journal-dir "~/dev/org/journal/"))

(defun org-insert-img-link ()
  "Inserts default img attributes and asks for img link."
  (interactive)
  (insert "#+ATTR_ORG: :width 100\n")
  (org-insert-link))
