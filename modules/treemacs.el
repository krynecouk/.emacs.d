(use-package treemacs
  :bind ("M-1" . 'treemacs)
  :config
  (treemacs-resize-icons 16)
  :custom
  (treemacs-follow-mode t)
  (treemacs-width 80)
  :bind (:map treemacs-mode-map
              ("C-c C-c" . 'treemacs-create-file)
              ("C-c C-d" . 'treemacs-delete-file)
              ("C-c C-r" . 'treemacs-rename-file)
              ("C-c C-m" . 'treemacs-move-file)
              ("C-c C-y" . 'treemacs-copy-file))
  )
