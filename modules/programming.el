;; -*- lexical-binding: t; -*-

(import '("git" "yaml" "python" "just" "lsp" "kubernetes"))

;; Custom functions

(defun my/copy-file-line ()
  "Copy the current file path and line number to the kill ring.
In visual mode, copies a line range like ~/dev/foo/README.md:110-122.
Otherwise, copies a single line like ~/dev/foo/README.md:122."
  (interactive)
  (if-let* ((file (buffer-file-name))
            (path (abbreviate-file-name file)))
      (let* ((in-visual (use-region-p))
             (start-line (if in-visual
                             (line-number-at-pos (region-beginning))
                           (line-number-at-pos)))
             (end-line (when in-visual
                         (line-number-at-pos (region-end))))
             (ref (if (and in-visual (/= start-line end-line))
                      (format "%s:%d-%d" path start-line end-line)
                    (format "%s:%d" path start-line))))
        (kill-new ref)
        (message "%s" ref))
    (message "Buffer is not visiting a file")))
