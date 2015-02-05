;;; .emacs --- Mike Kofron's emacs configuration
;;; Commentary:

;;; Code:
(eval-when-compile (require 'cl))
(add-to-list 'load-path (concat user-emacs-directory "modules"))

(require 'init-packages)

(require 'init-appearance)
(require 'init-completion)
(require 'init-evil)
;(require 'init-helm)
(require 'init-ido)
(require 'init-indentation)
(require 'init-projectile)
(require 'init-snippets)
(require 'init-syntax)
(require 'init-whitespace)

(add-hook 'after-init-hook '(lambda ()
                              (require 'init-keybindings)
                              ))

(setq make-backup-files nil)

(provide '.emacs)
;;; .emacs ends here
