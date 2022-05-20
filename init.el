(defun path (package)
  (concat user-emacs-directory (concat "/packages/" (concat package ".el"))))

(defun load-package (package)
  (load-file (path package)))

(defun switch-to-previous-buffer ()
  "Switch to most recent buffer. Repeated calls toggle back and forth between the most recent two buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

;; packages
(load-package "core")
(load-package "org")
(load-package "evil")
(load-package "vertico")

;; mappings
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
(global-set-key (kbd "C-`") 'switch-to-previous-buffer)
