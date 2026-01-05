;; -*- lexical-binding: t; -*-

(set-face-attribute 'default nil :family "Roboto Mono" :height 130 :weight 'regular :width 'normal)
(setq-default line-spacing 0.1)

;; Minimal modeline - hide minor modes, only show major mode
(setq mode-line-modes
      (list (propertize "%[" 'help-echo "Recursive edit, type C-M-c to get out")
            '(:propertize ("" mode-name)
                          help-echo "Major mode\nmouse-1: Display major mode menu"
                          mouse-face mode-line-highlight
                          local-map mode-line-major-mode-keymap)
            (propertize "%]" 'help-echo "Recursive edit, type C-M-c to get out")
            "  "))

;; (import '("ef-themes" "mood-line"))

(import '("doom-theme"))
