;; install packages
(unless (package-installed-p 'vertico)
  (package-install 'vertico))

(vertico-mode 1)
