(import '("popper" "perspective" "center" "super-save"))

(defun quit-other-window ()
  (interactive)
  (quit-window nil (other-window 1)))

(bind-key "Q" 'quit-other-window)
