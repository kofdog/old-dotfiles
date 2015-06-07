;;; init-keybindings.el --- define keybindings for stock emacs (i.e. without packages)
;;; Commentary:

;;; Code:
;; Buffer navigation
; Remove old bindings
;(global-unset-key (kbd "C-x h"))
;(global-unset-key (kbd "C-x l"))

; Define new ones (vim-like)
;(global-set-key (kbd "C-x h") 'previous-buffer)
;(global-set-key (kbd "C-x l") 'next-buffer)

(provide 'init-keybindings)
;;; init-keybindings.el ends here
