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

;; install straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
