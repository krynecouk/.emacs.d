;; -*- lexical-binding: t; -*-

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)   ; make all Dired buffers Dirvish
  :custom
  ;; Enable icons, file info, and other visual enhancements
  (dirvish-attributes
   '(nerd-icons          ; show icons (requires nerd-icons package)
     file-size           ; show file sizes
     collapse            ; smart path collapsing
     git-msg             ; show git commit message
     file-time))         ; show modification time

  ;; Preview options
  (dirvish-preview-dispatchers '(image gif video audio))

  ;; Cache for better performance
  (dirvish-cache-dir (expand-file-name "dirvish" user-emacs-directory))

  ;; Use the full frame for dirvish-side
  (dirvish-side-width 35)

  :bind
  (("M-1" . dirvish-side)
   :map dirvish-mode-map
   ("TAB" . dirvish-subtree-toggle)      ; tree structure: expand/collapse with TAB
   ("M-TAB" . dirvish-subtree-up)        ; go up one level
   ("M-n" . dirvish-narrow)              ; narrow to matching files
   ("f" . dirvish-file-info-menu)        ; file info
   ("y" . dirvish-yank-menu)             ; copy/move menu
   ("s" . dirvish-quicksort)             ; sort options
   ("?" . dirvish-dispatch))             ; action menu

  :config
  ;; Enable mouse support
  (dirvish-peek-mode))

;; Required for nerd-icons support
(use-package nerd-icons
  :ensure t)
