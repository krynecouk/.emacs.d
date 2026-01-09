;; -*- lexical-binding: t; -*-

(use-package perspective
  :init
  (persp-mode)
  :bind (("M-t" . persp-switch)
	 ("M-o" . my/project-open-in-persp)
	 ("M-]" . persp-next)
	 ("M-r" . persp-rename)
	 ("M-[" . persp-prev)
	 ("M-`" . persp-switch-last))
  :custom
  (persp-initial-frame-name "scratch")
  (persp-mode-prefix-key (kbd "C-x x"))
  :config
  (defun my/project-open-in-persp ()
    "Open project in a perspective. Select ... to browse for a new project."
    (interactive)
    (let* ((input (completing-read "Project: " (cons "..." (project-known-project-roots)) nil t))
           (dir (if (string= input "...") (read-directory-name "Directory: ") input))
           (name (file-name-nondirectory (directory-file-name dir)))
           (new-p (not (member name (persp-names)))))
      (persp-switch name)
      (when new-p (project-switch-project dir)))))
