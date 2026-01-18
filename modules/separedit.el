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
  (setq separedit-default-mode 'markdown-mode))

(provide 'separedit)
