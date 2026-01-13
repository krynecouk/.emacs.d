;; -*- lexical-binding: t; -*-

(use-package dimmer
  :init
  (setq dimmer-fraction 0.4)
  (setq dimmer-adjustment-mode :foreground)
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-mode t))
