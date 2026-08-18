;; -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(ert-deftest my/codex-disables-codex-vim-mode ()
  (should
   (cl-loop for (flag value) on codex-program-switches
            thereis (and (equal flag "-c")
                         (equal value "tui.vim_mode_default=false")))))
