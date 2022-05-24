(defun path (module)
  (concat user-emacs-directory (concat "/modules/" (concat module ".el"))))

(defun load-module (module)
  (load-file (path module)))

(setq package-enable-at-startup nil)
