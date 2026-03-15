;; -*- lexical-binding: t; -*-

(use-package obsidian
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode t)
  :custom
  (obsidian-directory "~/dev/Obsidian")
  (obsidian-inbox-directory "inbox")
  (obsidian-links-use-vault-path t)
  (markdown-enable-wiki-links t)
  :bind (:map obsidian-mode-map
              ("C-c o o" . obsidian-capture)
              ("C-c o b" . obsidian-backlink-jump)))
