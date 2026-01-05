;; -*- lexical-binding: t; -*-

(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :ensure t)

(add-hook 'prog-mode-hook 'copilot-mode)
(define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)

;; (with-eval-after-load 'copilot
;;   (evil-define-key 'insert copilot-mode-map
;;     (kbd "<C-]>") #'copilot-next-completion)
;;     (kbd "<C-[>") #'copilot-previous-completion)
