;; -*- lexical-binding: t; -*-

;; Core dired settings
(use-package dired
  :straight nil
  :custom
  (dired-dwim-target t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t))

;; Sidebar using dired
(use-package dired-sidebar
  :bind ("M-1" . dired-sidebar-toggle-sidebar)
  :custom
  (dired-sidebar-width 40)
  (dired-sidebar-use-term-integration t)
  (dired-sidebar-use-custom-font nil))
