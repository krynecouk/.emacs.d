(defun one-metadata-frontend-lint ()
  (interactive)
  (async-shell-command "yarn nx run one-metadata-frontend:lint"))

(defun one-metadata-frontend-serve ()
  (interactive)
  (async-shell-command "yarn nx run one-metadata-frontend:serve"))

(defun one-metadata-frontend-build ()
  (interactive)
  (async-shell-command "yarn nx run one-metadata-frontend:build"))

(defun dmm-lint ()
  (interactive)
  (async-shell-command "yarn nx run dmm-core:lint"))

(defun dmm-test ()
  (interactive)
  (async-shell-command "yarn nx run dmm-core:test"))

(defun dmm-build ()
  (interactive)
  (async-shell-command "yarn nx run dmm-core:build"))

(defun one-metadata-frontend-e2e ()
  (interactive)
  (let ((test-name (read-string "Enter new test name: ")))
    (async-shell-command (format "yarn playwright test --config=apps/one-metadata-frontend-e2e/playwright.config.ts --debug -g ") test-name)))
