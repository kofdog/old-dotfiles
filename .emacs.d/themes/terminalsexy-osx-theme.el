;;; terminalsexy-osx-theme.el --- Pulled from a random unixporn post
;;; Commentary:

;;; Code:
(deftheme terminalsexy-osx)

(let ((background "#19282b")
      (current-line "#0e1a1d")
      (selection "#0e1a1d")
      (foreground "#ffffff")
      (comment "#3e4f59")
      (cursor "#ff5a2f")
      (red "#ff8ebc")
      (orange "#ff5a2f")
      (yellow "#c4b994")
      (green "#d5eba0")
      (aqua "#a6e9d5")
      (blue "#a2cedd")
      (purple "#b777fb"))

  (custom-theme-set-faces
   'terminalsexy-osx

   ;; Built-in stuff (Emacs 23)
   `(default ((((class color) (min-colors 256)) (:background ,background :foreground ,foreground))))
   `(fringe ((((class color) (min-colors 256)) (:background ,current-line))))
   `(minibuffer-prompt ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(mode-line ((((class color) (min-colors 256)) (:background ,current-line :foreground ,foreground))))
   `(region ((((class color) (min-colors 256)) (:background ,selection))))

   ;; Term faces
   `(term-color-black ((((class color) (min-colors 256)) (:foreground ,background))))
   `(term-color-red ((((class color) (min-colors 256)) (:foreground ,red))))
   `(term-color-green ((((class color) (min-colors 256)) (:foreground ,green))))
   `(term-color-yellow ((((class color) (min-colors 256)) (:foreground ,yellow))))
   `(term-color-blue ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(term-color-purple ((((class color) (min-colors 256)) (:foreground ,purple))))
   `(term-color-cyan ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(term-color-white ((((class color) (min-colors 256)) (:foreground ,foreground))))

   ;; Font-lock stuff
   `(font-lock-comment-face ((((class color) (min-colors 256)) (:foreground ,comment))))
   `(font-lock-constant-face ((((class color) (min-colors 256)) (:foreground ,green))))
   `(font-lock-doc-string-face ((((class color) (min-colors 256)) (:foreground ,comment))))
   `(font-lock-function-name-face ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(font-lock-keyword-face ((((class color) (min-colors 256)) (:foreground ,purple))))
   `(font-lock-string-face ((((class color) (min-colors 256)) (:foreground ,green))))
   `(font-lock-type-face ((((class color) (min-colors 256)) (:foreground ,yellow))))
   `(font-lock-variable-name-face ((((class color) (min-colors 256)) (:foreground ,red))))
   `(font-lock-warning-face ((((class color) (min-colors 256)) (:foreground ,red))))

   ;; hl-line-mode
   `(hl-line ((((class color) (min-colors 256)) (:background ,current-line))))

   ;; linum-mode
   `(linum ((((class color) (min-colors 256)) (:background ,current-line :foreground ,foreground))))

   ;; org-mode
   `(org-date ((((class color) (min-colors 256)) (:foreground ,purple))))
   `(org-done ((((class color) (min-colors 256)) (:foreground ,green))))
   `(org-hide ((((class color) (min-colors 256)) (:foreground ,current-line))))
   `(org-link ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(org-todo ((((class color) (min-colors 256)) (:foreground ,red))))

   ;; show-paren-mode
   `(show-paren-match ((((class color) (min-colors 256)) (:background ,blue :foreground ,current-line))))
   `(show-paren-mismatch ((((class color) (min-colors 256)) (:background ,orange :foreground ,current-line))))

   ;; rainbow-delimiters
   `(rainbow-delimiters-depth-1-face ((((class color) (min-colors 256)) (:foreground ,purple))))
   `(rainbow-delimiters-depth-2-face ((((class color) (min-colors 256)) (:foreground ,blue))))
   `(rainbow-delimiters-depth-3-face ((((class color) (min-colors 256)) (:foreground ,aqua))))
   `(rainbow-delimiters-depth-4-face ((((class color) (min-colors 256)) (:foreground ,green))))
   `(rainbow-delimiters-depth-5-face ((((class color) (min-colors 256)) (:foreground ,yellow))))
   `(rainbow-delimiters-depth-6-face ((((class color) (min-colors 256)) (:foreground ,orange))))
   `(rainbow-delimiters-depth-7-face ((((class color) (min-colors 256)) (:foreground ,red))))
   `(rainbow-delimiters-depth-8-face ((((class color) (min-colors 256)) (:foreground ,comment))))
   `(rainbow-delimiters-depth-9-face ((((class color) (min-colors 256)) (:foreground ,foreground)))))

  (custom-theme-set-variables
   'terminalsexy-osx

   `(ansi-color-names-vector
     ;; black, red, green, yellow, blue, magenta, cyan, white
     [,background ,red ,green ,yellow ,blue ,purple ,blue ,foreground])
   `(when (not (facep (aref ansi-term-color-vector 0)))
      (ansi-term-color-vector
       ;; black, red, green, yellow, blue, magenta, cyan, white
       [unspecified ,background ,red ,green ,yellow ,blue ,purple ,blue ,foreground]))))

(provide-theme 'terminalsexy-osx)

;;; terminalsexy-osx-theme.el ends here
