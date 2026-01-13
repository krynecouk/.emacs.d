;; -*- lexical-binding: t; -*-

(use-package vterm
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  :bind (:map vterm-mode-map
              ("C-c C-t" . 'vterm-new)
              ("C-<tab>" . 'claude-toggle)
              ("M-`" . 'persp-switch-last)
              ("M-t" . 'persp-switch))
  :hook (vterm-mode . hide-line-numbers))


(defun vterm-new ()
  (interactive)
  (let ((new-name (read-string "Enter new buffer name: ")))
    (rename-buffer new-name)
    (vterm)))

(defun claude-buffer-p (buffer)
  "Return non-nil if BUFFER is a Claude Code buffer."
  (string-match-p "\\*[Cc]laude" (buffer-name buffer)))

(defvar claude-toggle--previous-window nil
  "Window configuration before showing Claude buffer.")

(defun claude-toggle ()
  "Toggle the most recent Claude Code vterm buffer in current perspective.
If currently in a Claude buffer, restore the previous window configuration.
If a Claude buffer exists and is visible, hide it.
If a Claude buffer exists but is not visible, show it.
Otherwise, display a message that no Claude buffer was found."
  (interactive)
  (if (claude-buffer-p (current-buffer))
      (when claude-toggle--previous-window
        (set-window-configuration claude-toggle--previous-window)
        (setq claude-toggle--previous-window nil))
    (let ((persp-buffers (if (bound-and-true-p persp-mode)
                             (persp-buffers (persp-curr))
                           (buffer-list))))
      (if-let* ((buf (seq-find #'claude-buffer-p persp-buffers)))
          (if-let* ((win (get-buffer-window buf)))
              (delete-window win)
            (setq claude-toggle--previous-window (current-window-configuration))
            (pop-to-buffer buf))
        (message "No Claude buffer found in current perspective")))))

(use-package vterm-toggle
  :bind (("C-`" . vterm-toggle)
         ("C-<tab>" . claude-toggle))
  :custom
  (vterm-toggle-scope 'project)
  :config
  (add-to-list 'vterm-toggle-togglable-buffer-functions
               (lambda (buf) (not (claude-buffer-p buf)))))

(use-package vterm-anti-flicker-filter
  :straight (:type git :host github :repo "martinbaillie/vterm-anti-flicker-filter")
  :after vterm
  :hook (vterm-mode . vterm-anti-flicker-filter-enable))

(defun vterm-font-setup ()
  "Configure font settings specifically for vterm buffers, workaround claude-code."
  ;; Apply ASCII replacements for vterm specifically
  (let ((tbl (or buffer-display-table (setq buffer-display-table (make-display-table)))))
    (dolist (pair
	     '((#x273B . ?*) ; ✻ TEARDROP-SPOKED ASTERISK
	       (#x273D . ?*) ; ✽ HEAVY TEARDROP-SPOKED ASTERISK
	       (#x2722 . ?+) ; ✢ FOUR TEARDROP-SPOKED ASTERISK
	       (#x2736 . ?+) ; ✶ SIX-POINTED BLACK STAR
	       (#x2733 . ?*) ; ✳ EIGHT SPOKED ASTERISK
	       ))
      (aset tbl (car pair) (vector (cdr pair))))))

(add-hook 'vterm-mode-hook #'vterm-font-setup)
