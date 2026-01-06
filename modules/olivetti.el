;; -*- lexical-binding: t; -*-

(use-package olivetti
  :ensure t
  :config
  ;; Make the text area wider (default is 70)
  (setq olivetti-body-width 140)

  ;; Increase font size when olivetti mode is active
  (defvar my/olivetti-font-scale 1
    "Text scale level for olivetti mode. Integer: 0=default, 1=slightly larger, 2-3=much larger.")

  (defun my/olivetti-scale-up ()
    "Increase text scale when entering olivetti mode."
    (text-scale-set my/olivetti-font-scale))

  (defun my/olivetti-scale-down ()
    "Reset text scale when exiting olivetti mode."
    (text-scale-set 0))

  (add-hook 'olivetti-mode-on-hook #'my/olivetti-scale-up)
  (add-hook 'olivetti-mode-off-hook #'my/olivetti-scale-down)

  ;; Keybinding to toggle olivetti mode
  :bind ("C-c z" . olivetti-mode))
