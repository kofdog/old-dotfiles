;;; init-whitespace.el --- Configure whitespace removal
;;; Commentary:

;;; Code:
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(provide 'init-whitespace)
;;; init-whitespace.el ends here
