(defun path (package)
  (concat user-emacs-directory (concat "/packages/" (concat package ".el"))))

(defun load-package (package)
  (load-file (path package)))

;; packages
(load-package "core")
(load-package "org")
(load-package "evil")
(load-package "vertico")

;; mappings
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
