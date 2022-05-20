(unless (package-installed-p 'projectile)
  (package-install 'projectile))

(projectile-mode 1)
;; (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
