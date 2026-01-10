;; -*- lexical-binding: t; -*-

(use-package centered-window
  :ensure t
  :config
  ;; Make the text area wider (default is 80)
  (setq cwm-centered-window-width 160)

  ;; Increase font size when centered-window mode is active
  (defvar my/centered-window-font-scale 1
    "Text scale level for centered-window mode. Integer: 0=default, 1=slightly larger, 2-3=much larger.")

  (defun my/centered-window-scale-up ()
    "Increase text scale when entering centered-window mode."
    (text-scale-set my/centered-window-font-scale))

  (defun my/centered-window-scale-down ()
    "Reset text scale when exiting centered-window mode."
    (text-scale-set 0))

  (defun my/centered-window-toggle-scale ()
    "Toggle text scale based on centered-window-mode state."
    (if centered-window-mode
        (my/centered-window-scale-up)
      (my/centered-window-scale-down)))

  (add-hook 'centered-window-mode-hook #'my/centered-window-toggle-scale)

  ;; Keybinding to toggle centered-window mode
  :bind ("C-c z" . centered-window-mode))
