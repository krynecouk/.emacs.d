;; -*- lexical-binding: t; -*-

;; Must be set before evil loads
(setq evil-want-keybinding nil)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-commentary
  :config
  (evil-commentary-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1)
  (add-to-list 'evil-surround-pairs-alist '(?` . my/surround-code-block)))

(use-package evil-leader
  :config
  (global-evil-leader-mode 1)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "gg" 'magit
    "pp" 'project-switch-project
    "pw" 'save-buffer
    "ff" 'format-or-indent
    "<SPC>" 'project-find-file
    "*" 'deadgrep
    "," 'consult-project-buffer
    "tt" 'dired-sidebar-toggle-sidebar
    "x" 'execute-extended-command))

(use-package evil-goggles
  :config
  (evil-goggles-mode 1))

(use-package evil-quickscope
  :config
  (global-evil-quickscope-mode 1))

(use-package evil
  :init
  (setq evil-esc-delay 0.001)
  :custom
  (evil-want-C-u-scroll t)
  (evil-undo-system 'undo-redo)
  (evil-search-module 'evil-search)
  (evil-respect-visual-line-mode t)
  :config
  (evil-ex-define-cmd "ls" 'persp-buffer-menu)
  (evil-ex-define-cmd "term" 'vterm-toggle)
  (evil-ex-define-cmd "Q" 'persp-kill)
  (setq evil-want-C-u-scroll t)
  ;; Make j/k move by visual lines instead of actual lines
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  ;; macOS-style copy in visual mode
  (define-key evil-visual-state-map (kbd "M-c") 'evil-yank)
  (evil-mode 1))

;; Custom functions

(defun format-or-indent ()
  (interactive)
  (cond
   ((equal major-mode 'web-mode) (prettier-prettify))
   ;; ((eglot-managed-p) (eglot-format-buffer))
   (t (indent-region (point-min) (point-max) nil))))

(defun my/surround-code-block ()
  "Return code block delimiters, prompting for optional language."
  (let ((lang (read-string "Language (optional): ")))
    (if (derived-mode-p 'org-mode)
        (cons (if (string-empty-p lang)
                  "#+begin_src "
                (format "#+begin_src %s " lang))
              " #+end_src")
      (cons (format "```%s " lang) " ```"))))
