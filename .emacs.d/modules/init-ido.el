;;; init-ido.el --- Configure ido
;;; Commentary:

;;; Code:
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)
(setq ido-separator "\n")
(setq ido-ignore-buffers '("\\` " "^\*"))

(defun bind-ido-keys()
  "Keybindings for ido mode."
  (define-key ido-completion-map (kbd "C-j") 'ido-next-match)
  (define-key ido-completion-map (kbd "C-k") 'ido-prev-match))

(add-hook 'ido-setup-hook #'bind-ido-keys)

(provide 'init-ido)
;;; init-ido.el ends here
