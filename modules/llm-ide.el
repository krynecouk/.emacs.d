;; -*- lexical-binding: t; -*-

;; Unified front-end over claude-code and codex-ide. The backend modules
;; own all package-specific config; this module only adds a registry and
;; dispatch commands, and rebinds the shared keys last so it wins.

(import '("claude-code" "codex-ide"))

;; Each backend maps the unified operations to its own (already interactive)
;; commands. Adding an agent = adding an entry here.
(defvar my/llm-ide-backends
  '((claude . (:start claude-code
               :buffer-p claude-code--buffer-p
               :project-buffers my/llm-ide--claude-project-buffers
               :stop claude-code-kill
               :send claude-code-send-command-with-context
               :escape claude-code-send-escape
               :cycle-mode claude-code-cycle-mode
               :rename my/claude-code-rename-buffer
               :menu claude-code-transient))
    (codex . (:start my/codex-ide-start
              :buffer-p codex-ide--session-buffer-p
              :project-buffers my/codex-ide--project-buffers
              :stop my/codex-ide-stop
              :send codex-ide-prompt
              :escape codex-ide-interrupt
              :cycle-mode codex-ide-agent-config-menu
              :rename my/codex-ide-rename-buffer
              :menu codex-ide-menu)))
  "Registry of agent backends for the unified commands.")

(defvar my/llm-ide-command-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "c") #'my/llm-ide-start)
    (define-key map (kbd "k") #'my/llm-ide-kill)
    (define-key map (kbd "t") #'my/llm-ide-toggle)
    (define-key map (kbd "TAB") #'my/llm-ide-toggle)
    (define-key map (kbd "s") #'my/llm-ide-send-with-context)
    (define-key map (kbd "m") #'my/llm-ide-cycle-mode)
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
(bind-key "C-c c" my/llm-ide-command-map)

(defun my/llm-ide--claude-project-buffers ()
  "Claude session buffers for the current project."
  (claude-code--find-claude-buffers-for-directory (claude-code--directory)))

(defun my/llm-ide--backend-of (buffer)
  "Return the backend plist owning BUFFER, or nil."
  (cl-some (lambda (backend)
             (when (funcall (plist-get (cdr backend) :buffer-p) buffer)
               (cdr backend)))
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
  "Kill the active project agent."
  (interactive)
  (my/llm-ide--dispatch :stop))

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

(defun my/llm-ide-rename-buffer ()
  "Rename the active project agent buffer."
  (interactive)
  (my/llm-ide--dispatch :rename))

(defun my/llm-ide-menu ()
  "Open the active project agent's menu."
  (interactive)
  (my/llm-ide--dispatch :menu))
