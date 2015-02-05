;;; init-completion.el --- Configure autocompletion
;;; Commentary:

;;; Code:
(require 'auto-complete)
(require 'auto-complete-config)

(setq ac-auto-show-menu t)
(setq ac-auto-start t)
(setq ac-quick-help-delay 0.3)
(setq ac-quick-help-height 30)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-use-fuzzy t)

(ac-config-default)

(provide 'init-completion)
;;; init-completion.el ends here
