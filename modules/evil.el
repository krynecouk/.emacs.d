(use-package evil-collection
  :init
  (setq evil-want-keybinding nil)
  :config (evil-collection-init))

(use-package evil-commentary
  :config (evil-commentary-mode 1))

(use-package evil-surround
  :config (evil-surround-mode 1))

(use-package evil-leader
  :config (global-evil-leader-mode 1)
	   (evil-leader/set-leader "<SPC>")
	   (evil-leader/set-key
	     "gg" 'magit))

(use-package evil
  :init (setq
	  evil-search-module 'evil-search
	  evil-undo-system 'undo-redo
	  evil-want-C-u-scroll t
	  evil-want-keybinding nil
	  evil-respect-visual-line-mode t)
  :config (evil-mode 1))
