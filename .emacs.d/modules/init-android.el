;;; init-android.el --- Configure android-mode for Android development.
;;; Commentary:

;;; Code:
(require 'android-mode)
(setq android-mode-sdk-dir "/mnt/data/Android/Sdk")
(add-hook 'java-mode-hook '(lambda () (android-mode)))

(provide 'init-android)
;;; init-android.el ends here
