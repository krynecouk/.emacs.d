(use-package org
  :config
  (setq org-indent-mode t)
  :custom
  (org-startup-indented t)
  (org-src-preserve-indentation t)
  (org-return-follows-link t)
  (org-src-fontify-natively t)
  (org-babel-load-languages
   '((emacs-lisp . t)
     ))
  (org-src-tab-acts-natively t))
