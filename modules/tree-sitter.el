(use-package tree-sitter)

(use-package tree-sitter-langs
  :after tree-sitter
  :config
  (add-to-list 'tree-sitter-major-mode-language-alist '(web-mode . typescript)))
