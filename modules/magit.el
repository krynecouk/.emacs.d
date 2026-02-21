;; -*- lexical-binding: t; -*-

(use-package magit
  :bind (("C-c g w w" . magit-worktree)
         ("C-c g w k" . magit-worktree-delete)
         ("C-c g w g" . magit-worktree-checkout)
         ("C-c g w c" . magit-worktree-add)
         ("C-c g w b" . magit-worktree-branch))
  :config
  (define-key magit-section-mode-map (kbd "C-<tab>") nil)
  (evil-define-key 'normal magit-status-mode-map (kbd "Z") #'magit-worktree))
