(use-package popper
  :bind (("C-`"   . popper-toggle-latest)
         ("C-M-`" . popper-toggle-type)
         ("C-M-<tab>"  . popper-cycle))
  :config
  (popper-mode 1)
  (popper-echo-mode 1)
  :custom
  (popper-group-function 'popper-group-by-perspective)
  (popper-window-height 25)
  (popper-reference-buffers '("\\*Messages\\*"
                              "Output\\*$"
                              "\\*Async Shell Command\\*"
                              help-mode
                              ;; "magit:.\*"
                              "\\*deadgrep.\*"
                              "\\*eldoc.\*"
                              "\\*xref\\*"
                              "\\*direnv\\*"
                              "\\*Warnings\\*"
                              "\\*Bookmark List\\*"
			      ;; "^\\*vterm.*\\*$"  vterm-mode
                              compilation-mode)))
