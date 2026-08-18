# Codex Session Folder Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `~/dev` multi-picker to new Emacs Codex sessions and disable Codex's internal Vim mode for those sessions.

**Architecture:** Keep the behavior in `modules/codex.el`, split into small helpers for candidate discovery, selection, and CLI argument construction. Advise Codex's new-session buffer boundary so existing buffers and resume/fork paths bypass the picker, while a static Emacs-only CLI override disables the TUI's Vim mode.

**Tech Stack:** Emacs Lisp, `use-package`, Codex CLI startup flags, ERT, batch Emacs.

## Global Constraints

- The current project remains the primary Codex workspace and must not be repeated as `--add-dir`.
- Candidates are immediate child directories of `~/dev`; discovery must not recurse.
- Empty selection is valid and adds no CLI flags.
- Existing-session switching and resume/fork behavior must not prompt.
- Codex's internal Vim mode is disabled only for Emacs-launched sessions.
- Do not modify the user's global `~/.codex/config.toml`.

## File structure

- Modify `modules/codex.el`: configure the Vim override and own discovery, picker, argument, and startup-advice functions.
- Create `test/codex-test.el`: focused ERT coverage for the module behavior.

---

### Task 1: Disable Codex Vim mode for Emacs sessions

**Files:**
- Modify: `modules/codex.el`
- Create: `test/codex-test.el`

**Interfaces:**
- Consumes: Codex package variable `codex-program-switches`.
- Produces: an adjacent `"-c"`, `"tui.vim_mode_default=false"` pair in `codex-program-switches`.

- [ ] **Step 1: Write the failing configuration test**

Create `test/codex-test.el` with:

```elisp
;; -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(ert-deftest my/codex-disables-codex-vim-mode ()
  (should
   (cl-loop for (flag value) on codex-program-switches
            thereis (and (equal flag "-c")
                         (equal value "tui.vim_mode_default=false")))))
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  --eval '(ert-run-tests-batch-and-exit "my/codex-disables-codex-vim-mode")'
```

Expected: FAIL because `codex-program-switches` does not contain the override.

- [ ] **Step 3: Add the Emacs-only CLI override**

In the `:init` section of `use-package codex`, immediately after `codex-confirm-kill`, add:

```elisp
  ;; Evil is the modal editing layer inside Emacs; a second Vim state machine
  ;; in the Codex TUI consumes input before it can be displayed.
  (setq codex-program-switches '("-c" "tui.vim_mode_default=false"))
```

- [ ] **Step 4: Run the focused test and verify GREEN**

Run the command from Step 2.

Expected: PASS with one test and zero unexpected results.

- [ ] **Step 5: Commit the input-mode change**

```bash
git add -f test/codex-test.el
git add modules/codex.el
git commit -m "Disable Codex Vim mode in Emacs"
```

---

### Task 2: Discover and select immediate `~/dev` projects

**Files:**
- Modify: `modules/codex.el`
- Modify: `test/codex-test.el`

**Interfaces:**
- Produces: `my/codex-projects-directory`, defaulting to `~/dev/`.
- Produces: `(my/codex--additional-directory-choices CURRENT-DIR) -> ((DISPLAY-NAME . ABSOLUTE-DIR) ...)`.
- Produces: `(my/codex--read-additional-directories CURRENT-DIR) -> (ABSOLUTE-DIR ...)`.
- Produces: `(my/codex--add-dir-switches DIRECTORIES) -> ("--add-dir" DIR ...)`.

- [ ] **Step 1: Add failing discovery and argument tests**

Append to `test/codex-test.el`:

```elisp
(ert-deftest my/codex-discovers-only-immediate-other-directories ()
  (let* ((root (make-temp-file "codex-projects-" t))
         (current (expand-file-name "current/" root))
         (current-link (expand-file-name "current-link" root))
         (alpha (expand-file-name "alpha/" root))
         (zebra (expand-file-name "zebra/" root))
         (my/codex-projects-directory root))
    (unwind-protect
        (progn
          (make-directory current)
          (make-directory (expand-file-name "nested/" alpha) t)
          (make-directory zebra)
          (make-symbolic-link current current-link)
          (write-region "not a directory" nil
                        (expand-file-name "notes.txt" root))
          (should
           (equal (my/codex--additional-directory-choices current)
                  `(("alpha" . ,alpha)
                    ("zebra" . ,zebra)))))
      (delete-directory root t))))

(ert-deftest my/codex-missing-projects-directory-has-no-choices ()
  (let ((my/codex-projects-directory
         (expand-file-name "missing" temporary-file-directory)))
    (should-not
     (my/codex--additional-directory-choices default-directory))))

(ert-deftest my/codex-reads-multiple-additional-directories ()
  (let* ((root (make-temp-file "codex-projects-" t))
         (alpha (expand-file-name "alpha/" root))
         (zebra (expand-file-name "zebra/" root))
         (my/codex-projects-directory root))
    (unwind-protect
        (progn
          (make-directory alpha)
          (make-directory zebra)
          (cl-letf (((symbol-function 'completing-read-multiple)
                     (lambda (&rest _) '("zebra" "alpha"))))
            (should
             (equal (my/codex--read-additional-directories default-directory)
                    (list zebra alpha)))))
      (delete-directory root t))))

(ert-deftest my/codex-builds-repeated-add-dir-switches ()
  (should
   (equal (my/codex--add-dir-switches '("/tmp/one/" "/tmp/two/"))
          '("--add-dir" "/tmp/one/" "--add-dir" "/tmp/two/")))
  (should-not (my/codex--add-dir-switches nil)))
```

- [ ] **Step 2: Run the new tests and verify RED**

Run:

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  --eval '(ert-run-tests-batch-and-exit "my/codex-\\(discovers\\|missing\\|reads\\|builds\\)")'
```

Expected: FAIL because the variable and helper functions are undefined.

- [ ] **Step 3: Implement candidate discovery**

Add after the `use-package codex` form in `modules/codex.el`:

```elisp
(defcustom my/codex-projects-directory "~/dev/"
  "Directory whose immediate children can be added to Codex sessions."
  :type 'directory
  :group 'codex)

(defun my/codex--additional-directory-choices (current-dir)
  "Return selectable child directories, excluding CURRENT-DIR by true name."
  (let ((root (expand-file-name my/codex-projects-directory)))
    (when (and (file-directory-p root) (file-readable-p root))
      (condition-case nil
          (let ((current-true (file-name-as-directory
                               (file-truename current-dir))))
            (sort
             (cl-loop for path in (directory-files
                                   root t directory-files-no-dot-files-regexp)
                      when (and (file-directory-p path)
                                (not (equal current-true
                                            (file-name-as-directory
                                             (file-truename path)))))
                      collect (cons
                               (file-name-nondirectory (directory-file-name path))
                               (file-name-as-directory (expand-file-name path))))
             (lambda (left right) (string-lessp (car left) (car right)))))
        (file-error nil)))))
```

- [ ] **Step 4: Implement the picker and flag builder**

Add below the discovery function:

```elisp
(defun my/codex--read-additional-directories (current-dir)
  "Read additional Codex directories for CURRENT-DIR from `~/dev`."
  (when-let* ((choices (my/codex--additional-directory-choices current-dir))
              (selected (completing-read-multiple
                         (format "Add projects (current: %s): "
                                 (abbreviate-file-name current-dir))
                         choices nil t)))
    (delq nil
          (mapcar (lambda (name) (alist-get name choices nil nil #'string=))
                  selected))))

(defun my/codex--add-dir-switches (directories)
  "Return repeated Codex --add-dir switches for DIRECTORIES."
  (cl-loop for directory in directories
           append (list "--add-dir" directory)))
```

- [ ] **Step 5: Run all tests through Task 2 and verify GREEN**

Run:

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  -f ert-run-tests-batch-and-exit
```

Expected: all five tests pass with zero unexpected results.

- [ ] **Step 6: Commit candidate discovery and selection**

```bash
git add modules/codex.el
git add -f test/codex-test.el
git commit -m "Add Codex project directory picker"
```

---

### Task 3: Attach selected directories only to new sessions

**Files:**
- Modify: `modules/codex.el`
- Modify: `test/codex-test.el`

**Interfaces:**
- Consumes: `my/codex--read-additional-directories` and `my/codex--add-dir-switches` from Task 2.
- Produces: advice function `my/codex-add-project-directories` matching `codex--start-session-buffer`'s eight arguments.

- [ ] **Step 1: Add failing launch-boundary tests**

Append to `test/codex-test.el`:

```elisp
(ert-deftest my/codex-adds-selected-directories-to-new-session ()
  (let (captured-switches)
    (cl-letf (((symbol-function 'my/codex--read-additional-directories)
               (lambda (_dir) '("/tmp/one/" "/tmp/two/"))))
      (my/codex-add-project-directories
       (lambda (_dir _backend _instance switches _resume-id
                     _initial-prompt _switch-after)
         (setq captured-switches switches))
       "/tmp/current/" 'vterm "default" '("--existing") nil nil nil))
    (should
     (equal captured-switches
            '("--existing" "--add-dir" "/tmp/one/"
              "--add-dir" "/tmp/two/")))))

(ert-deftest my/codex-empty-selection-preserves-switches ()
  (let (captured-switches)
    (cl-letf (((symbol-function 'my/codex--read-additional-directories)
               (lambda (_dir) nil)))
      (my/codex-add-project-directories
       (lambda (_dir _backend _instance switches _resume-id
                     _initial-prompt _switch-after)
         (setq captured-switches switches))
       "/tmp/current/" 'vterm "default" '("--existing") nil nil nil))
    (should (equal captured-switches '("--existing")))))

(ert-deftest my/codex-resume-bypasses-directory-picker ()
  (let (captured-switches)
    (cl-letf (((symbol-function 'my/codex--read-additional-directories)
               (lambda (_dir) (ert-fail "picker called for resume"))))
      (my/codex-add-project-directories
       (lambda (_dir _backend _instance switches _resume-id
                     _initial-prompt _switch-after)
         (setq captured-switches switches))
       "/tmp/current/" 'vterm "default" '("--existing")
       "session-id" nil nil))
    (should (equal captured-switches '("--existing")))))

(ert-deftest my/codex-app-server-bypasses-directory-picker ()
  (let (captured-switches)
    (cl-letf (((symbol-function 'my/codex--read-additional-directories)
               (lambda (_dir) (ert-fail "picker called for app-server"))))
      (my/codex-add-project-directories
       (lambda (_dir _backend _instance switches _resume-id
                     _initial-prompt _switch-after)
         (setq captured-switches switches))
       "/tmp/current/" 'app-server "default" nil nil nil nil))
    (should-not captured-switches)))
```

- [ ] **Step 2: Run the launch tests and verify RED**

Run:

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  --eval '(ert-run-tests-batch-and-exit "my/codex-\\(adds-selected\\|empty-selection\\|resume\\|app-server\\)")'
```

Expected: FAIL because `my/codex-add-project-directories` is undefined.

- [ ] **Step 3: Implement the new-session advice**

Add below the picker helpers in `modules/codex.el`:

```elisp
(defun my/codex-add-project-directories
    (orig-fn dir backend instance extra-switches resume-id
             initial-prompt switch-after)
  "Add selected project directories when ORIG-FN starts a new terminal session."
  (let ((switches
         (if (or resume-id (eq backend 'app-server))
             extra-switches
           (append extra-switches
                   (my/codex--add-dir-switches
                    (my/codex--read-additional-directories dir))))))
    (funcall orig-fn dir backend instance switches resume-id
             initial-prompt switch-after)))

(advice-add 'codex--start-session-buffer
            :around #'my/codex-add-project-directories)
```

- [ ] **Step 4: Run the complete ERT suite and verify GREEN**

Run:

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  -f ert-run-tests-batch-and-exit
```

Expected: all nine tests pass with zero unexpected results.

- [ ] **Step 5: Verify module loading and CLI argument construction**

Run:

```bash
emacs --batch -l early-init.el -l init.el \
  --eval '(progn
            (unless (equal (my/codex--add-dir-switches
                            '("/tmp/one/" "/tmp/two/"))
                           '("--add-dir" "/tmp/one/"
                             "--add-dir" "/tmp/two/"))
              (kill-emacs 1))
            (princ "Codex module verification passed\n"))'
```

Expected: exit status 0 and `Codex module verification passed`.

- [ ] **Step 6: Commit the startup integration**

```bash
git add modules/codex.el
git add -f test/codex-test.el
git commit -m "Add folders to new Codex sessions"
```

---

### Task 4: Final verification

**Files:**
- Verify: `modules/codex.el`
- Verify: `test/codex-test.el`

**Interfaces:**
- Consumes: the complete behavior from Tasks 1-3.
- Produces: fresh evidence that the configuration loads and all focused regressions pass.

- [ ] **Step 1: Run whitespace and repository checks**

```bash
git diff HEAD~3 --check
git status --short
```

Expected: no whitespace errors; only intentional commits and no uncommitted files.

- [ ] **Step 2: Run the complete focused suite from a fresh batch Emacs**

```bash
emacs --batch -l early-init.el -l init.el -l test/codex-test.el \
  -f ert-run-tests-batch-and-exit
```

Expected: nine tests pass with zero unexpected results.

- [ ] **Step 3: Inspect the final diff against the approved design**

```bash
git diff b669f0e..HEAD -- modules/codex.el test/codex-test.el
```

Confirm that the diff implements every global constraint and contains no unrelated refactoring.
