;; -*- lexical-binding: t; -*-

(use-package vterm
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  (defun vterm-new ()
    (interactive)
    (let ((new-name (read-string "Enter new buffer name: ")))
      (rename-buffer new-name)
      (vterm)))
  :bind (:map vterm-mode-map
              ("C-c C-t" . 'vterm-new)
              ("M-`" . 'persp-switch-last)
              ("M-t" . 'persp-switch))
  :hook (vterm-mode . hide-line-numbers))

(use-package vterm-toggle
  :bind ("C-`" . vterm-toggle)
  :custom
  (vterm-toggle-scope 'project)
  :config
  ;; Filter out Claude Code vterm buffers from vterm-toggle
  (defun vterm-toggle-not-claude-code-p (buffer)
    "Return non-nil if BUFFER is not a Claude Code vterm buffer."
    (not (string-match-p "\\*claude-code\\[" (buffer-name buffer))))
  (add-to-list 'vterm-toggle-togglable-buffer-functions
               #'vterm-toggle-not-claude-code-p))

(use-package vterm-anti-flicker-filter
  :straight (:type git :host github :repo "martinbaillie/vterm-anti-flicker-filter"))
