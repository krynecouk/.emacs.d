;; -*- lexical-binding: t; -*-

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  ;; (load-theme 'doom-Iosvkem t)
  (load-theme 'doom-xcode t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))
