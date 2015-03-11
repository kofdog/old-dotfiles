;;; init-backup.el --- Set appearance options
;;; Commentary:

;;; Code:
(setq
 backup-by-copying t
 backup-directory-alist
  '(("." . "~/.emacs.d/saves"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)

(provide 'init-backup)
;;; init-backup.el ends here
