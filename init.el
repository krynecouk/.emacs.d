(defun path (package)
  (concat user-emacs-directory (concat "/packages/" (concat package ".el"))))

(defun load-package (package)
  (load-file (path package)))

;; packages
(load-package "core")
(load-package "evil")

;; mappings
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
