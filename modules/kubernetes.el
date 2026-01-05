;; -*- lexical-binding: t; -*-

(use-package kubernetes
  :config
  (fset 'kubectl 'kubernetes-overview)
  (setq kubernetes-poll-frequency 3600
        kubernetes-redraw-frequency 3600))

(use-package kubernetes-evil
  :ensure t
  :after kubernetes)
