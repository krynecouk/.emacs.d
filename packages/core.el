;; force cmd as meta
(setq mac-command-modifier 'meta)                   

;; disable some gcc warns
(setq native-comp-async-report-warnings-errors nil) 

;; columns settings
(setq display-line-numbers 'relative)
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-current-absolute t)
(global-display-line-numbers-mode t)

;; ui
(menu-bar-mode 0)                                   
(when (display-graphic-p)                           
  (tool-bar-mode 0)                                 
  (scroll-bar-mode 0))                              
(setq inhibit-startup-screen t)                     
(setq initial-scratch-message nil)
(load-theme 'modus-vivendi t)                       
(setq ring-bell-function 'ignore)                   
(setq show-paren-delay 0)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(global-visual-line-mode)
;; (visual-line-mode 1)
(setq-default word-wrap t)


;; write auto-saves, backups and customs to separate directory
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t)))
(setq backup-directory-alist '(("." . "~/.tmp/emacs/backup/")))
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq custom-file (concat user-emacs-directory "/custom.el"))

;; enable installation of packages from MELPA & ELPA
(require 'package)
(add-to-list 'package-archives '(("melpa" . "https://melpa.org/packages/")
				 ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
