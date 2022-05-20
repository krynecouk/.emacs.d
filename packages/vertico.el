(defun switch-to-previous-buffer ()
  "Switch to most recent buffer. Repeated calls toggle back and forth between the most recent two buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(unless (package-installed-p 'vertico)
  (package-install 'vertico))

(vertico-mode 1)

;; mappings
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
(global-set-key (kbd "C-`") 'switch-to-previous-buffer)

