;; -*- lexical-binding: t; -*-

(use-package vterm
  :config
  (defun hide-line-numbers ()
    (display-line-numbers-mode 0))
  :bind (:map vterm-mode-map
              ("C-c C-t" . 'vterm-new)
              ("M-`" . 'persp-switch-last)
              ("M-t" . 'persp-switch))
  :hook (vterm-mode . hide-line-numbers))

(defun vterm-new ()
  (interactive)
  (let ((new-name (read-string "Enter new buffer name: ")))
    (rename-buffer new-name)
    (vterm)))

(use-package vterm-toggle
  :custom
  (vterm-toggle-scope 'project))

(global-set-key (kbd "C-`") #'my/vterm-toggle)

(use-package vterm-anti-flicker-filter
  :straight (:type git :host github :repo "martinbaillie/vterm-anti-flicker-filter")
  :after vterm
  :hook (vterm-mode . vterm-anti-flicker-filter-enable))

(defun my/vterm-toggle ()
  "Toggle vterm, ignoring claude-code buffers."
  (interactive)
  (let* ((vterm-windows
          (cl-remove-if-not
           (lambda (win)
             (with-current-buffer (window-buffer win)
               (and (derived-mode-p 'vterm-mode)
                    (not (string-match-p "\\*claude" (buffer-name))))))
           (window-list))))
    (if vterm-windows
        ;; Regular vterm visible - hide it
        (delete-window (car vterm-windows))
      ;; No regular vterm visible - show/create one
      (vterm-toggle-show))))

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
