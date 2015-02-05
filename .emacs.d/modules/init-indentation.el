;;; init-indentation.el --- Configure indentation settings
;;; Commentary:

;;; Code:
(smart-tabs-mode 1)
(smart-tabs-insinuate 'c 'javascript)

(setq-default indent-tabs-mode nil)
(add-hook 'c-mode-common-hook '(lambda ()
                                 (setq indent-tabs-mode t)
                                 ))

(setq-default tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)

(provide 'init-indentation)
;;; init-indentation.el ends here
