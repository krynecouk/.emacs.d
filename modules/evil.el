(defun format-or-indent ()
  (interactive)
  (cond
   ((equal major-mode 'web-mode) (prettier-js))
   ;; ((eglot-managed-p) (eglot-format-buffer))
   (t (indent-region (point-min) (point-max) nil))))

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
  (global-evil-surround-mode 1))

(use-package evil-leader
  :config
  (global-evil-leader-mode 1)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "gg" 'magit
    "pp" 'project-switch-project
    "ff" 'format-or-indent
    "<SPC>" 'project-find-file
    "*" 'deadgrep
    "," 'project-switch-to-buffer
    "tt" 'treemacs-display-current-project-exclusively
    "ot" 'vterm-toggle
    "tz" 'centered-window-mode))

(use-package evil-goggles
  :config
  (evil-goggles-mode 1))

(use-package evil
  :custom
  (evil-want-C-u-scroll t)
  (evil-undo-system 'undo-redo)
  (evil-search-module 'evil-search)
  (evil-want-keybinding nil)
  (evil-respect-visual-line-mode t)
  :config
  (evil-ex-define-cmd "ls" 'persp-buffer-menu)
  (evil-ex-define-cmd "term" 'vterm-toggle)
  (setq evil-want-C-u-scroll t)
  (evil-mode 1))
