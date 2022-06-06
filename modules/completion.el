(defun yank-pop-indent ()
  "Yank, pop and indent the region."
  (interactive)
  (let ((point-before (point)))
    (consult-yank-pop)
    (indent-region point-before (point))))

(use-package vertico
  :config
  (vertico-mode 1)
  :bind
  ("C-x C-b" . 'switch-to-buffer)
  :custom
  (vertico-cycle t))

(use-package corfu
  :config
  (global-corfu-mode 1)
  :custom
  (corfu-cycle t))

(use-package consult
  :bind (:map
	 global-map
	 ("C-." . 'completion-at-point)
         ("C-h a"   . 'consult-apropos)
	 :map
	 evil-insert-state-map
	 ("TAB" . 'completion-at-point)
	 :map
	 evil-normal-state-map
	 ("m" . 'bookmark-set)
	 ("'" . 'consult-bookmark)
	 ("\"" . 'yank-pop-indent)
	 ("C-f" . 'consult-line)
	 ("M-f" . 'consult-ripgrep)
	 ("gs" . 'consult-imenu)
         ("g?"   . 'consult-flymake))
  :custom
  (completion-in-region-function 'consult-completion-in-region)
  (xref-show-xrefs-function 'consult-xref)
  (xref-show-definitions-function 'consult-xref)
  (consult-project-root-function 'deadgrep--project-root))

(use-package marginalia
  :config (marginalia-mode))

(use-package orderless
  :custom (completion-styles '(orderless)))

(use-package prescient
  :config (prescient-persist-mode))
