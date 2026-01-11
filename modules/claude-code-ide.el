;; -*- lexical-binding: t; -*-

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind (("C-c C-<tab>" . claude-code-ide-menu)
         ("C-<tab>" . claude-code-ide-toggle))
  :config
  (claude-code-ide-emacs-tools-setup))
