;; -*- lexical-binding: t; -*-

(use-package project
  :straight nil
  :custom
  (project-switch-commands #'project-find-file))

(global-set-key (kbd "M-p") 'project-find-file)
