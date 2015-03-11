;;; init-whitespace.el --- Configure whitespace removal
;;; Commentary:

;;; Code:
(setq require-final-newline t)
(setq mode-require-final-newline t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(provide 'init-whitespace)
;;; init-whitespace.el ends here
