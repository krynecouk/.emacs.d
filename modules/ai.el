;; -*- lexical-binding: t; -*-

(use-package gptel
  :config
  (evil-define-key 'normal gptel-context-buffer-mode-map
    (kbd "q") #'gptel-context-quit
    (kbd "n") #'gptel-context-next
    (kbd "p") #'gptel-context-previous
    (kbd "d") #'gptel-context-flag-deletion
    (kbd "RET") #'gptel-context-visit))

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind (("C-c C-'" . claude-code-ide-menu)
         ("C-<tab>" . claude-code-ide-toggle))
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

  ;; Fix Unicode character widths to reduce flickering
  ;; Claude uses spinner chars (✢✳∗✻✽) and bullets (⏺) with ambiguous East Asian width
  ;; Setting width to 1 prevents text jumping during animations
  (dolist (range '((#x23FA . #x23FA) ; ⏺ bullet
                   (#x2700 . #x27BF) ; Dingbats (spinner chars ✢✳✻✽)
                   (#x2200 . #x22FF))) ; Math operators (∗)
    (set-char-table-range char-width-table range 1))
