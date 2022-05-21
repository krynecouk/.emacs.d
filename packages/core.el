;; force cmd as meta
(setq mac-command-modifier 'meta)

;; disable some gcc warns
(setq native-comp-async-report-warnings-errors nil)

;; columns settings
(setq
 display-line-numbers 'relative
 display-line-numbers-type 'relative
 display-line-numbers-current-absolute t)
(global-display-line-numbers-mode t)

;; ui
(setq
 inhibit-startup-screen t
 initial-scratch-message nil
 ring-bell-function 'ignore
 show-paren-delay 0)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(load-theme 'modus-vivendi t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(global-visual-line-mode)
(visual-line-mode 1)


;; write auto-saves, backups and customs to separate directory
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq
 auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t))
 backup-directory-alist '(("." . "~/.tmp/emacs/backup/"))
 backup-by-copying t
 create-lockfiles nil
 custom-file (concat user-emacs-directory "/custom.el"))

;; enable installation of packages from MELPA & ELPA
(require 'package)
(add-to-list 'package-archives '(("melpa" . "https://melpa.org/packages/")
				 ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
