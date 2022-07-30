(use-package yasnippet-snippets)

(use-package consult-yasnippet)

(use-package yasnippet
  :defer 15
  :bind ("M-i" . 'yas/insert-snippet)
  :custom
  (yas-global-mode 1))
