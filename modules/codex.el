;; -*- lexical-binding: t; -*-

;; OpenAI Codex integration (benthamite/codex), configured to mirror
;; modules/claude-code.el: same vterm backend, same window layout, same
;; keybindings and helper commands. modules/llm-ide.el is the unified
;; front-end that dispatches over this and claude-code.

(use-package codex
  :straight (:type git :host github :repo "benthamite/codex" :branch "master" :depth 1)
  :init
  (setq codex-terminal-backend 'vterm)
  (setq codex-confirm-kill nil)
  ;; Evil is the modal editing layer inside Emacs; a second Vim state machine
  ;; in the Codex TUI consumes input before it can be displayed.
  (setq codex-program-switches '("-c" "tui.vim_mode_default=false"))
  ;; Equivalent of --dangerously-skip-permissions
  (setq codex-full-auto t)
  (add-to-list 'display-buffer-alist
               '("\\*codex"
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'codex-toggle)
  (bind-key* "M-<RET>" #'codex-send-command)
  (bind-key* "C-z" #'codex-toggle-read-only-mode)
  ;; Evil claims C-z (evil-toggle-key) in its state maps, which shadow bind-key*
  (with-eval-after-load 'evil
    (define-key evil-motion-state-map (kbd "C-z") nil)
    (define-key evil-insert-state-map (kbd "C-z") nil)
    (define-key evil-emacs-state-map (kbd "C-z") nil))
  :config
  (codex-mode)
  :bind-keymap ("C-c c" . codex-command-map)
  :bind (:map codex-command-map
              ("m" . codex-cycle-permissions)
              ("?" . codex-transient)
              ("<escape>" . codex-send-escape)
              ("RET" . codex-send-return)
              ("b" . my/codex-switch-buffer)
              (">" . my/codex-next-buffer)
              ("<" . my/codex-prev-buffer)
              ("`" . my/codex-toggle-last-buffer)
              ("n" . my/codex-rename-buffer)))


(defun my/codex-auto-select (orig-fn prompt buffers &optional simple-format)
  "Auto-select first buffer, unless killing—then let the user choose."
  (if (eq this-command 'codex-kill)
      (funcall orig-fn prompt buffers simple-format)
    (car buffers)))

(advice-add 'codex--select-buffer-from-choices :around #'my/codex-auto-select)

(defun my/codex-kill-close-window (orig-fn)
  "Kill Codex and close its window."
  (let ((win (cl-find-if (lambda (w) (codex--buffer-p (window-buffer w)))
                         (window-list))))
    (funcall orig-fn)
    (when (and win (window-live-p win) (> (length (window-list)) 1))
      (delete-window win))))

(advice-add 'codex-kill :around #'my/codex-kill-close-window)

(defun my/codex-close-existing-windows (orig-fn &rest args)
  "Close existing Codex windows before starting a new instance."
  (dolist (w (window-list))
    (when (and (codex--buffer-p (window-buffer w))
               (> (length (window-list)) 1))
      (delete-window w)))
  (apply orig-fn args))

(advice-add 'codex :around #'my/codex-close-existing-windows)

(defun my/codex-no-cross-project (orig-fn)
  "Prevent falling back to codex buffers from other projects."
  (let* ((current-dir (codex--directory))
         (dir-buffers (codex--find-codex-buffers-for-directory current-dir)))
    (if dir-buffers
        (funcall orig-fn)
      nil)))

(advice-add 'codex--get-or-prompt-for-buffer :around #'my/codex-no-cross-project)

(defun my/codex-send-prompt-for-buffer (orig-fn &optional arg)
  "Prompt for which codex buffer to send to when multiple exist."
  (let ((dir-buffers (codex--find-codex-buffers-for-directory (codex--directory))))
    (if (> (length dir-buffers) 1)
        (let* ((choices (codex--buffers-to-choices dir-buffers t))
               (selected (cdr (assoc (completing-read "Send to: " choices nil t) choices))))
          (when selected
            (cl-letf (((symbol-function 'codex--get-or-prompt-for-buffer)
                       (lambda () selected)))
              (funcall orig-fn arg))))
      (funcall orig-fn arg))))

(advice-add 'codex-send-command :around #'my/codex-send-prompt-for-buffer)

(defun my/codex-switch-buffer ()
  "Switch the codex side panel to a different project codex buffer."
  (interactive)
  (if-let* ((buffers (codex--find-codex-buffers-for-directory (codex--directory)))
            (choices (mapcar (lambda (b) (cons (codex--buffer-display-name b) b)) buffers))
            (selected (cdr (assoc (completing-read "Codex: " choices nil t) choices))))
      (progn
        (dolist (w (window-list))
          (when (codex--buffer-p (window-buffer w))
            (delete-window w)))
        (display-buffer selected))
    (message "No codex buffers for this project")))

(defun my/codex--visible-buffer ()
  "Return the currently visible codex buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (codex--buffer-p b) b)))
           (window-list)))

(defun my/codex--show-buffer (buf)
  "Close any visible codex window and display BUF."
  (dolist (w (window-list))
    (when (codex--buffer-p (window-buffer w))
      (delete-window w)))
  (display-buffer buf))

(defun my/codex--cycle (offset)
  "Cycle to codex buffer at OFFSET from the currently visible one."
  (let ((buffers (codex--find-codex-buffers-for-directory (codex--directory))))
    (if (< (length buffers) 2)
        (message "Only %d codex buffer(s) for this project" (length buffers))
      (let* ((current (my/codex--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/codex--show-buffer next)))))

(defun my/codex-next-buffer ()
  "Show the next project codex buffer in the side panel."
  (interactive)
  (my/codex--cycle 1))

(defun my/codex-prev-buffer ()
  "Show the previous project codex buffer in the side panel."
  (interactive)
  (my/codex--cycle -1))

(defun my/codex-rename-buffer ()
  "Rename the active codex buffer's instance label."
  (interactive)
  (if-let* ((dir (codex--directory))
            (buffers (codex--find-codex-buffers-for-directory dir))
            (buf (or (my/codex--visible-buffer) (car buffers))))
      (let* ((existing (mapcar (lambda (b)
                                 (or (codex--extract-instance-name-from-buffer-name
                                      (buffer-name b))
                                     "default"))
                               (remq buf buffers)))
             (label (codex--prompt-for-instance-name dir existing t)))
        (with-current-buffer buf
          (rename-buffer (codex--buffer-name label) t)))
    (message "No codex session for this project")))

(defun my/codex-toggle-last-buffer ()
  "Toggle between current and previous project codex buffer.
Swaps to whichever buffer isn't currently visible."
  (interactive)
  (let ((buffers (codex--find-codex-buffers-for-directory (codex--directory))))
    (if (< (length buffers) 2)
        (message "Only %d codex buffer(s) for this project" (length buffers))
      (let* ((current (my/codex--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/codex--show-buffer other)))))
