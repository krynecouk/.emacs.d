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
  (persp-state-default-file (expand-file-name "persp-state" user-emacs-directory))
  :config
  (add-hook 'kill-emacs-hook #'persp-state-save)
  (add-hook 'emacs-startup-hook #'my/persp-state-restore))

(defun my/persp-state-restore ()
  "Restore perspective state from file if it exists."
  (when (file-exists-p persp-state-default-file)
    (persp-state-load persp-state-default-file)))

(defun my/project-open-in-persp ()
  "Open project in a new perspective. Select ... to browse for a new project."
  (interactive)
  (let* ((input (completing-read "Project: " (cons "..." (project-known-project-roots)) nil t))
         (dir (if (string= input "...") (read-directory-name "Directory: ") input))
         (base-name (file-name-nondirectory (directory-file-name dir)))
         (name base-name)
         (counter 1))
    (while (member name (persp-names))
      (setq name (format "%s<%d>" base-name counter)
            counter (1+ counter)))
    (persp-switch name)
    (project-switch-project dir)))
