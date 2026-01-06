;; -*- lexical-binding: t; -*-

(use-package perspective
  :init
  (persp-mode)
  :bind (("M-t" . my/persp-switch-with-project)
	 ("M-]" . persp-next)
	 ("M-r" . persp-rename)
	 ("M-[" . persp-prev)
	 ("M-`" . persp-switch-last))
  :custom
  (persp-mode-prefix-key (kbd "C-x x"))
  :config
  (defun my/persp-switch-with-project ()
    "Switch to perspective and open project if new.
If switching to existing perspective with buffers, just switch.
If creating new perspective, prompt for project and auto-rename."
    (interactive)
    (let* ((persp-names (persp-names))
           (persp-name (completing-read "Perspective: " persp-names)))
      ;; Check if this is a new perspective
      (let ((is-new (not (member persp-name persp-names))))
        (persp-switch persp-name)
        ;; If new perspective, open project and rename
        (when is-new
          (let ((project (project-prompt-project-dir)))
            (when project
              (project-switch-project project)
              ;; Auto-rename perspective to project name
              (let ((project-name (file-name-nondirectory (directory-file-name project))))
                (persp-rename project-name)))))))))

(use-package treemacs-perspective
  :after treemacs perspective
  :config (treemacs-set-scope-type 'Perspectives))
