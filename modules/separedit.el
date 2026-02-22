;; -*- lexical-binding: t; -*-

(use-package separedit
  :bind (("C-c '" . separedit)
         :map prog-mode-map
         ("C-c '" . separedit)
         :map minibuffer-local-map
         ("C-c '" . separedit)
         :map help-mode-map
         ("C-c '" . separedit))
  :custom-face
  (separedit-region-face ((t (:background nil))))
  :config
  (setq enable-recursive-minibuffers t)
  (setq separedit-default-mode 'markdown-mode)
  (add-hook 'separedit-buffer-creation-hook #'my/separedit-inject-minibuffer-content))

(defvar my/separedit--captured-content nil)

(defun my/separedit-capture-context (&rest _)
  (setq my/separedit--captured-content
        (cond
         ((minibufferp)
          (minibuffer-contents))
         ((eq major-mode 'vterm-mode)
          (when-let* ((start (vterm--get-prompt-point)))
            (string-trim (buffer-substring-no-properties start (point-max))))))))

(advice-add 'separedit :before #'my/separedit-capture-context)

(defun my/separedit-inject-minibuffer-content ()
  (when (and my/separedit--captured-content
             (= (buffer-size) 0))
    (insert my/separedit--captured-content)
    (setq my/separedit--captured-content nil)))

(provide 'separedit)
