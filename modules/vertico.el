(defun switch-to-previous-buffer ()
  "Switch to most recent buffer. Repeated calls toggle back and forth between the most recent two buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(use-package vertico
  :config
  (vertico-mode 1)
  :bind
  ("C-x C-b" . 'switch-to-buffer)
  ("C-`" . 'switch-to-previous-buffer))

(use-package orderless
  :custom (completion-styles '(orderless)))

(use-package prescient
  :config (prescient-persist-mode))
