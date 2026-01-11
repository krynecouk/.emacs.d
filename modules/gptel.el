;; -*- lexical-binding: t; -*-

(use-package gptel
  :hook (gptel-mode . gptel-highlight-mode)
  :bind (("C-c RET" . gptel-send)
         ("C-c r" . gptel-rewrite)
         ("C-c ?" . gptel-menu))
  :config
  ;; (setq gptel-model 'gpt-5.1)
  (setq gptel-model 'gemini-3-flash-preview))

  (gptel-make-xai "xAI"
    :stream t
    :key #'gptel-api-key-from-auth-source)

  (gptel-make-gemini "Gemini"
    :stream t
    :key #'gptel-api-key-from-auth-source)
