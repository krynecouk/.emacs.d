(use-package evil-collection
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-collection-init))

(use-package evil-commentary
  :config
  (evil-commentary-mode 1))

(use-package evil-surround
  :config
  (evil-surround-mode 1))

(use-package evil-leader
  :config
  (global-evil-leader-mode 1)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "gg" 'magit
    "pp" 'project-switch-project
    "<SPC>" 'project-find-file
    "*" 'deadgrep
    "," 'project-switch-to-buffer
    "tt" 'treemacs-display-current-project-exclusively
    "ot" 'vterm-toggle
    "tz" 'centered-window-mode))

(use-package evil
  :init
  (setq
   evil-search-module 'evil-search
   evil-undo-system 'undo-redo
   evil-want-keybinding nil
   evil-respect-visual-line-mode t)
  :custom
  (evil-want-C-u-scroll t)
  :config
  (evil-ex-define-cmd "ls" 'persp-ibuffer)
  (evil-ex-define-cmd "term" 'vterm-toggle)
  (setq evil-want-C-u-scroll t)
  (evil-mode 1))
