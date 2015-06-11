;;; init-compilation.el --- Add compiling support for all languages.
;;; Commentary:

;;; Code:
(require 'cl)

;; Helper function to find files. Source: emacswiki
(defun* get-closest-pathname (&optional (file "Makefile"))
    "Determine the pathname of the first instance of FILE starting from the current directory towards root.
This may not do the correct thing in presence of links. If it does not find FILE, then it shall return
the current directory"
      (let ((root (expand-file-name "/")))
            (loop for d = default-directory
                            then (expand-file-name ".." d)
                                      if (file-exists-p (expand-file-name file d))  return d
                                                if (equal d root) return nil)))

;; Android
; Tries to locate the gradlew wrapper, and if found create and return
; a "make" string which changes into that directory and executes ./gradlew
; with assembleDebug by default.
;
; How to recognize compilation errors.
; For some reason, the errors returned when compilation is run from within emacs is:
;   :TournmanApplication:compileRelease/home/marius/p/tournman/android/workspace/TournmanProject/TournmanApplication/src/main/java/net/kjeldahl/tournman/TournmanActivity.java:153: error: ';' expected
;
; This regexp captures the filename and line number by looking for ":compile.*?(filename):(lineno):
(require 'compile)

(defun gradleMake ()
  (unless (file-exists-p "gradlew")
    (set (make-local-variable 'compile-command)
                        (let ((mkfile (get-closest-pathname "gradlew")))
                          (if mkfile
                              (progn (format "cd %s; ./gradlew assembleDebug" mkfile))))))
      (add-to-list 'compilation-error-regexp-alist '(":compile.*?\\(/.*?\\):\\([0-9]+\\): " 1 2)))

;; Hooks
(add-hook 'java-mode-hook 'gradleMake)

(provide 'init-compilation)
;;; init-compilation.el ends here
