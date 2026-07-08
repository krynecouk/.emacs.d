;; -*- lexical-binding: t; -*-

;; Claude Code via agent-shell (xenodium), configured to mirror
;; modules/claude-code.el. Not a terminal: sessions are ACP clients of
;; `claude-agent-acp' rendered in shell-maker buffers, so there is no raw
;; escape/return and no read-only toggle (buffers are always navigable) —
;; C-z keeps its evil binding here. Uses your existing `claude` CLI login.
;; Requires: npm install -g @agentclientprotocol/claude-agent-acp
;; No CLI flag pass-through, so filevine --plugin-dir flags don't apply.
;; NOTE: import only one AI terminal module at a time in ai.el (C-<tab>,
;; M-RET and C-c c would conflict).

;; Defined before use-package so the C-c c binding below can reference it
(defvar my/agent-shell-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") #'agent-shell-anthropic-start-claude-code)
    (define-key map (kbd "C") #'agent-shell) ; DWIM: reuse/create, carries context
    (define-key map (kbd "k") #'my/agent-shell-kill)
    (define-key map (kbd "t") #'my/agent-shell-toggle)
    (define-key map (kbd "s") #'agent-shell-send-dwim)
    (define-key map (kbd "R") #'agent-shell-restart)
    (define-key map (kbd "m") #'my/agent-shell-cycle-mode)
    (define-key map (kbd "?") #'agent-shell-help-menu)
    (define-key map (kbd "<escape>") #'my/agent-shell-interrupt)
    (define-key map (kbd "b") #'my/agent-shell-switch-buffer)
    (define-key map (kbd ">") #'my/agent-shell-next-buffer)
    (define-key map (kbd "<") #'my/agent-shell-prev-buffer)
    (define-key map (kbd "`") #'my/agent-shell-toggle-last-buffer)
    map)
  "Command map for agent-shell, mirroring claude-code-command-map.")

(use-package agent-shell
  :straight t ; MELPA; straight pulls acp + shell-maker deps
  :init
  (setq agent-shell-preferred-agent-config 'claude-code)
  (setq agent-shell-session-strategy 'new)
  ;; Equivalent of --dangerously-skip-permissions
  (setq agent-shell-anthropic-default-session-mode-id "bypassPermissions")
  (setq agent-shell-permission-responder-function #'agent-shell-permission-allow-always)
  (setq agent-shell-confirm-interrupt nil)
  ;; Buffers are named "Claude Agent @ project": right side, 40%
  (add-to-list 'display-buffer-alist
               '("Agent @ "
                 (display-buffer-reuse-window display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.4)))
  ;; Force bindings to override mode-specific keymaps (e.g., magit, python-mode)
  (bind-key* "C-<tab>" #'my/agent-shell-toggle)
  (bind-key* "M-<RET>" #'my/agent-shell-send-with-context)
  (bind-key "C-c c" my/agent-shell-command-map))

(defun my/agent-shell--visible-buffer ()
  "Return the currently visible agent shell buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (with-current-buffer b (derived-mode-p 'agent-shell-mode)) b)))
           (window-list)))

(defun my/agent-shell--project-buffer ()
  "Return the visible or most recent agent shell for this project, or nil."
  (or (my/agent-shell--visible-buffer)
      (car (agent-shell-project-buffers))))

(defun my/agent-shell--show-buffer (buf)
  "Close any visible agent shell window and display BUF."
  (dolist (w (window-list))
    (when (with-current-buffer (window-buffer w) (derived-mode-p 'agent-shell-mode))
      (delete-window w)))
  (display-buffer buf))

(defun my/agent-shell-toggle ()
  "Toggle the agent shell side panel for the current project.
Unlike `agent-shell-toggle', never falls back to other projects' shells."
  (interactive)
  (if-let* ((visible (my/agent-shell--visible-buffer)))
      (delete-window (get-buffer-window visible))
    (if-let* ((buffers (agent-shell-project-buffers)))
        (display-buffer (car buffers))
      (message "No agent shell for this project"))))

(defun my/agent-shell-send-with-context (text)
  "Send TEXT to the project's agent shell with file/line or region context."
  (interactive "sClaude command: ")
  (if-let* ((shell (car (agent-shell-project-buffers))))
      (let* ((cwd (with-current-buffer shell (agent-shell-cwd)))
             (ctx (if (use-region-p)
                      (agent-shell--get-region-context :deactivate t :no-error t
                                                       :agent-cwd cwd)
                    (agent-shell--get-current-line-context :agent-cwd cwd))))
        (agent-shell-insert :shell-buffer shell
                            :text (if ctx (concat text "\n\n" ctx) text)
                            :submit t
                            :no-focus t))
    (message "No agent shell for this project")))

(defun my/agent-shell-cycle-mode ()
  "Cycle session mode (default/acceptEdits/plan/bypassPermissions)."
  (interactive)
  (if-let* ((buf (my/agent-shell--project-buffer)))
      (with-current-buffer buf
        (agent-shell-cycle-session-mode))
    (message "No agent shell for this project")))

(defun my/agent-shell-interrupt ()
  "Interrupt the project's agent shell without confirmation."
  (interactive)
  (if-let* ((buf (my/agent-shell--project-buffer)))
      (with-current-buffer buf
        (agent-shell-interrupt t))
    (message "No agent shell for this project")))

(defun my/agent-shell-kill ()
  "Kill an agent shell for this project and close its window."
  (interactive)
  (if-let* ((buf (my/agent-shell--project-buffer)))
      (let ((win (get-buffer-window buf)))
        (kill-buffer buf)
        (when (and win (window-live-p win) (> (length (window-list)) 1))
          (delete-window win)))
    (message "No agent shell for this project")))

(defun my/agent-shell-switch-buffer ()
  "Switch the side panel to a different project agent shell."
  (interactive)
  (if-let* ((buffers (agent-shell-project-buffers))
            (choices (mapcar (lambda (b) (cons (buffer-name b) b)) buffers))
            (selected (cdr (assoc (completing-read "Agent: " choices nil t) choices))))
      (my/agent-shell--show-buffer selected)
    (message "No agent shells for this project")))

(defun my/agent-shell--cycle (offset)
  "Cycle to agent shell buffer at OFFSET from the currently visible one."
  (let ((buffers (agent-shell-project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d agent shell(s) for this project" (length buffers))
      (let* ((current (my/agent-shell--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/agent-shell--show-buffer next)))))

(defun my/agent-shell-next-buffer ()
  "Show the next project agent shell in the side panel."
  (interactive)
  (my/agent-shell--cycle 1))

(defun my/agent-shell-prev-buffer ()
  "Show the previous project agent shell in the side panel."
  (interactive)
  (my/agent-shell--cycle -1))

(defun my/agent-shell-toggle-last-buffer ()
  "Toggle between current and previous project agent shell."
  (interactive)
  (let ((buffers (agent-shell-project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d agent shell(s) for this project" (length buffers))
      (let* ((current (my/agent-shell--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/agent-shell--show-buffer other)))))
