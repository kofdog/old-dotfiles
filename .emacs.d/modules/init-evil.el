;;; init-evil.el --- Configure evil mode
;;; Commentary:

;;; Code:
(require 'evil)
(evil-mode 1)

;; Plugins
(require 'evil-surround)
(global-evil-surround-mode 1)

;; Keybindings
; Bind 'jk' to escape
(define-key evil-insert-state-map (kbd "j") #'cofi/maybe-exit)
;(define-key evil-visual-state-map (kbd "j") #'cofi/maybe-exit)
(evil-define-command cofi/maybe-exit ()
  :repeat change
  (interactive)
  (let ((modified (buffer-modified-p)))
    (insert "j")
    (let ((evt (read-event (format "Insert %c to exit insert state" ?k)
			   nil 0.5)))
      (cond
       ((null evt) (message ""))
       ((and (integerp evt) (char-equal evt ?k))
	(delete-char -1)
	(set-buffer-modified-p modified)
	(push 'escape unread-command-events))
       (t (setq unread-command-events (append unread-command-events
					       (list evt))))))))

; Remove horrible 'record' function
(define-key evil-normal-state-map (kbd "q") nil)

; Move by visible lines
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
(define-key evil-normal-state-map (kbd "gj") 'evil-next-line)
(define-key evil-normal-state-map (kbd "gk") 'evil-previous-line)

; Page up/down
(define-key evil-normal-state-map (kbd "C-j") (lambda ()
                                                (interactive)
                                                (evil-scroll-down nil)))
(define-key evil-normal-state-map (kbd "C-k") (lambda ()
                                                (interactive)
                                                (evil-scroll-up nil)))

(provide 'init-evil)
;;; init-evil.el ends here
