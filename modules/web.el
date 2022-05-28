(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.js\\'" . web-mode)
         ("\\.css\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.ts\\'" . web-mode)
         ("\\.tsx\\'" . web-mode))
  :hook (web-mode . company-mode)
  :config
  (add-to-list 'eglot-server-programs '((web-mode) "typescript-language-server" "--stdio"))
  :custom
  (web-mode-attr-indent-offset 2)
  (web-mode-block-padding 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-comment-style 2)
  (web-mode-enable-current-element-highlight t)
  (web-mode-markup-indent-offset 2))
