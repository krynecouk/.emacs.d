;; -*- lexical-binding: t; -*-

;; Unified front-end over claude-code and codex. The backend modules
;; own all package-specific config; this module only adds a registry and
;; dispatch commands, and rebinds the shared keys last so it wins.

(import '("claude-code" "codex"))

;; Each backend maps the unified operations to its own (already interactive)
;; commands. Adding an agent = adding an entry here.
(defvar my/llm-ide-backends
  '((claude . (:start claude-code
               :resume claude-code-resume
               :buffer-p claude-code--buffer-p
               :project-buffers my/llm-ide--claude-project-buffers
               :kill claude-code--kill-buffer
               :send claude-code-send-command-with-context
               :escape claude-code-send-escape
               :cycle-mode claude-code-cycle-mode
               :read-only claude-code-toggle-read-only-mode
               :rename my/claude-code-rename-buffer
               :menu claude-code-transient))
    (codex . (:start codex
              :resume codex-resume
              :buffer-p codex--buffer-p
              :project-buffers my/llm-ide--codex-project-buffers
              :kill codex--kill-buffer
              :send codex-send-command-with-context
              :escape codex-send-escape
              :cycle-mode codex-cycle-permissions
              :read-only codex-toggle-read-only-mode
              :rename my/codex-rename-buffer
              :menu codex-transient)))
  "Registry of agent backends for the unified commands.")

(defvar my/llm-ide-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") #'my/llm-ide-start)
    (define-key map (kbd "R") #'my/llm-ide-resume)
    (define-key map (kbd "k") #'my/llm-ide-kill)
    (define-key map (kbd "t") #'my/llm-ide-toggle)
    (define-key map (kbd "TAB") #'my/llm-ide-toggle)
    (define-key map (kbd "s") #'my/llm-ide-send-with-context)
    (define-key map (kbd "m") #'my/llm-ide-cycle-mode)
    (define-key map (kbd "z") #'my/llm-ide-toggle-read-only)
    (define-key map (kbd "?") #'my/llm-ide-menu)
    (define-key map (kbd "<escape>") #'my/llm-ide-escape)
    (define-key map (kbd "n") #'my/llm-ide-rename-buffer)
    (define-key map (kbd "b") #'my/llm-ide-switch-buffer)
    (define-key map (kbd ">") #'my/llm-ide-next-buffer)
    (define-key map (kbd "<") #'my/llm-ide-prev-buffer)
    (define-key map (kbd "`") #'my/llm-ide-toggle-last-buffer)
    map)
  "Unified command map dispatching over `my/llm-ide-backends'.")

(bind-key* "C-<tab>" #'my/llm-ide-toggle)
(bind-key* "M-<RET>" #'my/llm-ide-send-with-context)
;; Rebind after claude-code's own `bind-key*' so this wins and C-z no longer
;; hijacks codex buffers into a claude window. Evil's C-z is already cleared
;; by claude-code.el's state-map fixup.
(bind-key* "C-z" #'my/llm-ide-toggle-read-only)
(bind-key "C-c c" my/llm-ide-command-map)

(defun my/llm-ide--claude-project-buffers ()
  "Claude session buffers for the current project."
  (when (fboundp 'claude-code--find-claude-buffers-for-directory)
    (claude-code--find-claude-buffers-for-directory (claude-code--directory))))

(defun my/llm-ide--codex-project-buffers ()
  "Codex session buffers for the current project."
  (when (fboundp 'codex--find-codex-buffers-for-directory)
    (codex--find-codex-buffers-for-directory (codex--directory))))

(defun my/llm-ide--backend-of (buffer)
  "Return the backend plist owning BUFFER, or nil.
A backend whose package is not loaded yet owns no buffers, so its
`:buffer-p' predicate is skipped until it is defined."
  (cl-some (lambda (backend)
             (let ((buffer-p (plist-get (cdr backend) :buffer-p)))
               (when (and (fboundp buffer-p) (funcall buffer-p buffer))
                 (cdr backend))))
           my/llm-ide-backends))

(defun my/llm-ide--project-buffers ()
  "Agent buffers for the current project across all backends."
  (cl-loop for (_ . plist) in my/llm-ide-backends
           append (funcall (plist-get plist :project-buffers))))

(defun my/llm-ide--visible-buffer ()
  "Return the currently visible agent buffer, or nil."
  (cl-some (lambda (w)
             (let ((b (window-buffer w)))
               (when (my/llm-ide--backend-of b) b)))
           (window-list)))

(defun my/llm-ide--target-buffer ()
  "Return the visible or most recently used project agent buffer."
  (or (my/llm-ide--visible-buffer)
      ;; (buffer-list) is MRU-ordered
      (let ((bufs (my/llm-ide--project-buffers)))
        (cl-find-if (lambda (b) (memq b bufs)) (buffer-list)))))

(defun my/llm-ide--dispatch (op)
  "Call OP of the backend owning the active project agent buffer."
  (if-let* ((buf (my/llm-ide--target-buffer))
            (backend (my/llm-ide--backend-of buf)))
      (call-interactively (plist-get backend op))
    (message "No agent for this project")))

(defun my/llm-ide--show-buffer (buf)
  "Close any visible agent window and display BUF."
  (dolist (w (window-list))
    (when (my/llm-ide--backend-of (window-buffer w))
      (delete-window w)))
  (display-buffer buf))

(defun my/llm-ide-start ()
  "Start an agent for this project, picking the backend."
  (interactive)
  (let* ((name (completing-read "Start agent: " (mapcar #'car my/llm-ide-backends) nil t))
         (backend (alist-get (intern name) my/llm-ide-backends)))
    (call-interactively (plist-get backend :start))))

(defun my/llm-ide-resume ()
  "Resume a past session for this project, picking the backend.
Each backend shows its own picker of resumable sessions."
  (interactive)
  (let* ((name (completing-read "Resume agent: " (mapcar #'car my/llm-ide-backends) nil t))
         (backend (alist-get (intern name) my/llm-ide-backends)))
    (call-interactively (plist-get backend :resume))))

(defun my/llm-ide-toggle ()
  "Toggle the side panel, showing the last used project agent buffer."
  (interactive)
  (if-let* ((visible (my/llm-ide--visible-buffer)))
      (delete-window (get-buffer-window visible))
    (if-let* ((buf (my/llm-ide--target-buffer)))
        (display-buffer buf)
      (message "No agent for this project"))))

(defun my/llm-ide-switch-buffer ()
  "Switch the side panel to any project agent buffer."
  (interactive)
  (if-let* ((buffers (my/llm-ide--project-buffers))
            (choices (mapcar (lambda (b) (cons (buffer-name b) b)) buffers))
            (selected (cdr (assoc (completing-read "Agent: " choices nil t) choices))))
      (my/llm-ide--show-buffer selected)
    (message "No agent buffers for this project")))

(defun my/llm-ide--cycle (offset)
  "Cycle to agent buffer at OFFSET from the currently visible one."
  (let ((buffers (my/llm-ide--project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d agent buffer(s) for this project" (length buffers))
      (let* ((current (my/llm-ide--visible-buffer))
             (idx (or (cl-position current buffers) 0))
             (next (nth (mod (+ idx offset) (length buffers)) buffers)))
        (my/llm-ide--show-buffer next)))))

(defun my/llm-ide-next-buffer ()
  "Show the next project agent buffer in the side panel."
  (interactive)
  (my/llm-ide--cycle 1))

(defun my/llm-ide-prev-buffer ()
  "Show the previous project agent buffer in the side panel."
  (interactive)
  (my/llm-ide--cycle -1))

(defun my/llm-ide-toggle-last-buffer ()
  "Toggle between current and previous project agent buffer."
  (interactive)
  (let ((buffers (my/llm-ide--project-buffers)))
    (if (< (length buffers) 2)
        (message "Only %d agent buffer(s) for this project" (length buffers))
      (let* ((current (my/llm-ide--visible-buffer))
             (other (if (eq current (car buffers)) (cadr buffers) (car buffers))))
        (my/llm-ide--show-buffer other)))))

(defun my/llm-ide-kill ()
  "Kill a project agent, asking which one when several exist."
  (interactive)
  (if-let* ((buffers (my/llm-ide--project-buffers))
            (choices (mapcar (lambda (b) (cons (buffer-name b) b)) buffers))
            (buf (if (cdr buffers)
                     (cdr (assoc (completing-read "Kill agent: " choices nil t) choices))
                   (car buffers))))
      (let ((win (get-buffer-window buf)))
        (funcall (plist-get (my/llm-ide--backend-of buf) :kill) buf)
        (when (and win (window-live-p win) (> (length (window-list)) 1))
          (delete-window win)))
    (message "No agent for this project")))

(defun my/llm-ide-send-with-context ()
  "Send a prompt with context to the active project agent."
  (interactive)
  (my/llm-ide--dispatch :send))

(defun my/llm-ide-escape ()
  "Interrupt the active project agent."
  (interactive)
  (my/llm-ide--dispatch :escape))

(defun my/llm-ide-cycle-mode ()
  "Cycle/configure the active project agent's permission mode."
  (interactive)
  (my/llm-ide--dispatch :cycle-mode))

(defun my/llm-ide-toggle-read-only ()
  "Toggle read-only mode for the active project agent buffer."
  (interactive)
  (my/llm-ide--dispatch :read-only))

(defun my/llm-ide-rename-buffer ()
  "Rename the active project agent buffer."
  (interactive)
  (my/llm-ide--dispatch :rename))

(defun my/llm-ide-menu ()
  "Open the active project agent's menu."
  (interactive)
  (my/llm-ide--dispatch :menu))
