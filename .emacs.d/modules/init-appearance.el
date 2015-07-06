;;; init-appearance.el --- Set appearance options
;;; Commentary:

;;; Code:
;; Hide bars to improve terminal experience
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(unless (display-graphic-p) (menu-bar-mode -1))

;; Color scheme
;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
;(load-theme 'base16-default t)
(require 'color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-eighties t)
;(require 'monokai-theme)
;(load-theme 'monokai t)

;; Mode line
(column-number-mode t)

;; Matching pairs
(show-paren-mode t)

;; TODO highlighting
(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords
             nil
             '(("\\<\\(FIXME\\|TODO\\|BUG\\):" 1 font-lock-warning-face t)))))

(provide 'init-appearance)
;;; init-appearance.el ends here
