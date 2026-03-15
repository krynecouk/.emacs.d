;; -*- lexical-binding: t; -*-

(use-package project
  :straight nil
  :custom
  (project-switch-commands #'project-find-file))

(use-package bookmark-in-project)

(global-set-key (kbd "M-p") 'project-find-file)
