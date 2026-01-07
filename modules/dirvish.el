;; -*- lexical-binding: t; -*-

(use-package dirvish
  :ensure t
  :custom
  ;; Enable icons, file info, and other visual enhancements
  (dirvish-attributes
   '(
     ;; nerd-icons          ; show icons (requires nerd-icons package)
     ;; file-size           ; show file sizes
     collapse            ; smart path collapsing
     ;; git-msg             ; show git commit message
     file-time))         ; show modification time

  ;; Preview options
  (dirvish-preview-dispatchers '(image gif video audio))

  ;; Cache for better performance
  (dirvish-cache-dir (expand-file-name "dirvish" user-emacs-directory))

  ;; Use the full frame for dirvish-side
  (dirvish-side-width 35)

  :bind
  ("M-1" . dirvish-side)

  :config
  (require 'dirvish-extras)
  (require 'dirvish-subtree)
  (dirvish-override-dired-mode)
  (dirvish-peek-mode)

  ;; Evil keybindings - use evil-collection's method
  (with-eval-after-load 'evil-collection-dired
    (evil-collection-define-key 'normal 'dired-mode-map
      "j" 'dired-next-line
      "k" 'dired-previous-line
      (kbd "TAB") 'dirvish-subtree-toggle
      (kbd "M-TAB") 'dirvish-subtree-up
      (kbd "M-n") 'dirvish-narrow
      "f" 'dirvish-file-info-menu
      "y" 'dirvish-yank-menu
      "s" 'dirvish-quicksort
      "?" 'dirvish-dispatch)))

;; Required for nerd-icons support
(use-package nerd-icons
  :ensure t)
