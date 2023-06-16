(import '("git" "project" "completion" "yasnippet" "lsp" "web" "markdown" "yaml" "kubernetes" "copilot" "python"))

(defun load-private-elisp ()
  (let ((root "~/dev/elisp"))
    (dolist (file (directory-files root))
      (when (string-suffix-p ".el" file)
	(load-file (concat root "/" file))))))

(load-private-elisp)
