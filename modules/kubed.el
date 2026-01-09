;; -*- lexical-binding: t; -*-

(use-package kubed
  :ensure t)

(keymap-global-set "C-c k" 'kubed-prefix-map)
