;; install packages
(dolist (package '(evil evil-collection evil-commentary evil-surround magit))
  (unless (package-installed-p package)
    (package-install package)))


;; evil configuration
(setq evil-undo-system 'undo-redo)
(setq evil-want-C-u-scroll t)
(setq evil-want-keybinding nil)

(require 'evil)
(when (require 'evil-collection nil t)
  (evil-collection-init))

(evil-commentary-mode 1)
(evil-mode 1)
(evil-surround-mode 1)

