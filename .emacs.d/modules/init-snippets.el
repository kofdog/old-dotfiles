;;; init-snippets.el --- Configure snippet utilization/creation
;;; Commentary:

;;; Code:
(require 'yasnippet)
(yas-global-mode 1)

(add-to-list 'yas-snippet-dirs (concat user-emacs-directory "snippets"))

(provide 'init-snippets)
;;; init-snippets.el ends here
