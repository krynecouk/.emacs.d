;; -*- lexical-binding: t; -*-

(setq
 modus-themes-mode-line '(accented borderless (padding 3))
 modus-themes-region '(bg-only)
 modus-themes-bold-constructs t
 modus-themes-italic-constructs t
 modus-themes-paren-match '(bold intense)
 modus-themes-syntax '(green-strings)
 modus-themes-org-blocks 'tinted-background
 modus-themes-subtle-line-numbers t
 modus-themes-completions
 '((matches . (background intense))
   (selection . (semibold accented intense))
   (popup . (accented)))
 modus-themes-headings
 '((1 . (rainbow overline background 1.2))
   (2 . (rainbow background 1.1))
   (3 . (rainbow bold))
   (t . (semilight))))

(load-theme 'modus-vivendi t)
