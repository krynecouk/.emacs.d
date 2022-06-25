(setq
 org-indent-mode t
 org-src-preserve-indentation t
 org-src-tab-acts-natively t
 org-src-fontify-natively t)

(add-hook 'org-mode-hook 'org-indent-mode)
