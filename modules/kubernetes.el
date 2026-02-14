;; -*- lexical-binding: t; -*-

(use-package kubernetes
  :bind ("C-c k k" . kubernetes-overview)
  :config
  (fset 'kubectl 'kubernetes-overview)
  (setq kubernetes-poll-frequency 0
        kubernetes-redraw-frequency 0))

(use-package kubernetes-evil
  :ensure t
  :after kubernetes)
