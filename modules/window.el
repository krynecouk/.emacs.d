(import '("popper" "perspective" "center" "super-save"))

(defun quit-other-window ()
  (interactive)
  (quit-window nil (other-window 1)))

(evil-define-key 'normal 'global "Q" 'quit-other-window)
;; (bind-key "Q" 'quit-other-window)
