;; -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(ert-deftest my/codex-disables-codex-vim-mode ()
  (should
   (cl-loop for (flag value) on codex-program-switches
            thereis (and (equal flag "-c")
                         (equal value "tui.vim_mode_default=false")))))

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
