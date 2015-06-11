;;; init-packages.el --- Summary
;;; Commentary:

;;; Code:
(eval-when-compile (require 'cl))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

; defvar is the correct way to declare global variables
; you might see setq as well, but setq is supposed to be used just to set variables,
; not create them.
(defvar required-packages
  '(
    ag
    android-mode
    async
    auto-complete
    color-theme-sanityinc-tomorrow
    evil
    evil-leader
    evil-surround
    fish-mode
    flx-ido
    flycheck
    ;helm
    ;monokai-theme
    octave-mode
    projectile
    smart-tabs-mode
    yasnippet
    ) "A list of packages to ensure are installed at launch.")

(defun packages-installed-p ()
  "A method to check if all packages are installed."
  (loop for p in required-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

; if not all packages are installed, check one by one and install the missing ones.
(unless (packages-installed-p)
  ; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'init-packages)
;;; init-packages.el ends here
