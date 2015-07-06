;;; init-evil.el --- Configure evil mode
;;; Commentary:

;;; Code:
;; Dependencies
(require 'projectile)
(require 'android-mode)

(require 'evil)
(require 'evil-leader)
(global-evil-leader-mode)
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

; Move by visible lines
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
(define-key evil-normal-state-map (kbd "gj") 'evil-next-line)
(define-key evil-normal-state-map (kbd "gk") 'evil-previous-line)

; Set leader key
(evil-leader/set-leader ";")

; Buffer navigation
(evil-leader/set-key "h" 'previous-buffer)
(evil-leader/set-key "l" 'next-buffer)
(evil-leader/set-key "b" 'ido-switch-buffer)
(evil-leader/set-key "k" 'kill-buffer)

; Quitting
(defun close-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))
(evil-leader/set-key "q" 'close-all-buffers)

; File switching
(defun maybe-projectile-find-file ()
  (interactive)
  (call-interactively
   (if (projectile-project-p)
       #'projectile-find-file
       #'ido-find-file)))
(evil-leader/set-key "f" 'maybe-projectile-find-file)
(evil-leader/set-key "a" 'projectile-find-other-file)

; Android development
(evil-leader/set-key "e" 'android-start-emulator)
(evil-leader/set-key "d" 'android-start-ddms)

; All development
(evil-leader/set-key "m" 'compile)

; Window navigation
(evil-leader/set-key "o" 'evil-window-next)

; Page up/down
;(define-key evil-normal-state-map (kbd "C-j")
;  (lambda () (interactive) (evil-scroll-down nil)))
;(define-key evil-normal-state-map (kbd "C-k")
;  (lambda () (interactive) (evil-scroll-up nil)))

(provide 'init-evil)
;;; init-evil.el ends here
