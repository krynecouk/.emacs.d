;; -*- lexical-binding: t; -*-

(use-package project
  :straight nil
  :custom
  (project-switch-commands
   '((project-find-file "Find file")
     (magit-project-status "Magit" ?g)
     (deadgrep "Grep" ?*)
     (consult-bookmark "Bookmark" ?b)
     (vterm-toggle "Term" ?t)))
  :bind
  ;; ("M-p" . project-find-file)
  ;; ("M-o" . project-switch-project)

  )

(global-set-key (kbd "M-p") 'project-find-file)
(global-set-key (kbd "M-o") 'project-switch-project)
