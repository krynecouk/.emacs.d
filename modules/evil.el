;; install
(straight-use-package 'evil)
(straight-use-package 'evil-collection)
(straight-use-package 'evil-commentary)
(straight-use-package 'evil-surround)
(straight-use-package 'evil-leader)

;; init
(setq
 evil-search-module 'evil-search
 evil-undo-system 'undo-redo
 evil-want-C-u-scroll t
 evil-want-keybinding nil
 evil-respect-visual-line-mode t)

;; config
(global-evil-leader-mode 1)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "gg" 'magit)

(evil-collection-init)
(evil-commentary-mode 1)
(evil-surround-mode 1)
(evil-mode 1)

