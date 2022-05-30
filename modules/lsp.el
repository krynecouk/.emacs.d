(use-package eglot
  :hook ((web-mode . eglot-ensure))
  :bind (:map
	 eglot-mode-map
         ("g-R" . eglot-rename)
         ("M-RET" . eglot-code-actions)
	 :map
	 evil-normal-state-map
	 ("g]" . flymake-goto-next-error)
	 ("g[" . flymake-goto-prev-error)
	 ("gi" . eglot-find-implementation))
  :config
  (setq eldoc-echo-area-use-multiline-p nil)
  (add-to-list #'eglot-server-programs '((web-mode) "typescript-language-server" "--stdio"))
  :custom
  (eglot-autoshutdown t))

;; TODO move to different module
(defun quit-other-window ()
  (interactive)
  (quit-window nil (other-window 1))
  (other-window 1))

(bind-key "Q" 'quit-other-window)
