;;; init-helm.el --- Configure incremental completion and selection narrowing framework
;;; Commentary:

;;; Code:
(require 'helm-config)

(setq helm-command-prefix-key "C-c h")
(setq helm-quick-update t)

(setq helm-apropos-fuzzy-match t)
(setq helm-bookmark-show-location t)
(setq helm-buffers-fuzzy-matching t)
(setq helm-file-cache-fuzzy-match t)
(setq helm-imenu-fuzzy-match t)
(setq helm-lisp-fuzzy-completion t)
(setq helm-locate-fuzzy-match t)
(setq helm-M-x-fuzzy-match t)
(setq helm-recentf-fuzzy-match t)
(setq helm-semantic-fuzzy-match t)

(helm-mode 1)

;(require 'helm-projectile)
;(helm-projectile-on)

(provide 'init-helm)
;;; init-helm.el ends here
