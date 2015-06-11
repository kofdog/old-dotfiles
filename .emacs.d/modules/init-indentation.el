;;; init-indentation.el --- Configure indentation settings
;;; Commentary:

;;; Code:
;; Linux kernel style
; By default, use the Linux kernel development style.
(smart-tabs-mode 1)
(smart-tabs-insinuate 'c 'javascript)

(setq-default indent-tabs-mode nil)
(add-hook 'c-mode-common-hook
          '(lambda ()
             (setq indent-tabs-mode t)))

(setq-default tab-width 8)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)

;; Exceptions
; Android
(add-hook 'java-mode-hook
          '(lambda ()
             (setq c-basic-offset 4
                   tab-width 4
                   indent-tabs-mode nil)))

(provide 'init-indentation)
;;; init-indentation.el ends here
