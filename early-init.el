(defun path (module)
  (concat user-emacs-directory (concat "/modules/" (concat module ".el"))))

(defun import-one (module)
  (load-file (path module)))

(defun import-multiple (modules)
  (cond
   ((null modules) '())
   (t
    (import-one (car modules))
    (import-multiple (cdr modules)))))

(defun import (modules)
  (cond
   ((atom modules) (import-one modules))
   (t
    (import-multiple modules))))

(setq package-enable-at-startup nil)
