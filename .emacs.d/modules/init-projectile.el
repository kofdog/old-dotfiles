;;; init-projectile.el --- Configure project searching
;;; Commentary:

;;; Code:
(require 'projectile)
(projectile-global-mode)
(setq projectile-indexing-method 'alien)
(setq projectile-enable-caching t)
(setq projectile-require-project-root t)
(setq projectile-completion-system 'ido)

(provide 'init-projectile)
;;; init-projectile.el ends here
