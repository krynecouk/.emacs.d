;; force cmd as meta
(setq mac-command-modifier 'meta)                   

;; disable some gcc warns
(setq native-comp-async-report-warnings-errors nil) 

;; hide window bar
(menu-bar-mode 0)                                   

;; hide emacs and scroll bars
(when (display-graphic-p)                           
  (tool-bar-mode 0)                                 
  (scroll-bar-mode 0))                              

;; don't show intro
(setq inhibit-startup-screen t)                     

;; no scratch message
(setq initial-scratch-message nil)

;; change default theme
(load-theme 'modus-vivendi t)                       

;; disable ring bell
(setq ring-bell-function 'ignore)                   

;; no paren delay
(setq show-paren-delay 0)

;; change windows size
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; column settings
(global-display-line-numbers-mode t)
(setq display-line-numbers-current-absolute nil)
(setq display-line-numbers 'relative)

;; org settings
(setq org-indent-mode t)
(setq org-src-preserve-indentation t)

;; write auto-saves and backups to separate directory
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t)))
(setq backup-directory-alist '(("." . "~/.tmp/emacs/backup/")))

;; do not move the current file while creating backup
(setq backup-by-copying t)

;; disable lockfiles
(setq create-lockfiles nil)

;; file search
(ido-mode 1)
(ido-everywhere)
(setq ido-enable-flex-matching t)
(fido-mode)

;; todo move to different config
;; enable installation of packages from MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

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

(evil-commentary-mode)
(setq global-evil-surround-mode 1)
(evil-mode 1)

;; move custom to different file
(setq custom-file (concat user-emacs-directory "/custom.el"))

;; Mappings
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
