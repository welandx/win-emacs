(add-to-list 'load-path (concat user-emacs-directory "site-lisp/TypePad"))
;; (add-to-list 'load-path (concat user-emacs-directory "site-lisp/TypePad/buffer-focus-hook"))

(require 'typepad)

;; (setq typepad-text-path (concat user-emacs-directory "site-lisp/TypePad/txt"))

(typepad-load-long)

(add-to-list 'meow-mode-state-list '(typepad-readonly-mode . motion))

;; ;; enable visual-fill-column-mode in typepad-mode and typepad-readonly-mode


;; (package-vc-install '(typepad :url "https://github.com/welandx/TypePad.el"))
;; (use-package typepad
;;   :hook
;;   (typepad-mode . visual-fill-column-mode)
;;   (typepad-readonly-mode . visual-fill-column-mode)
;;   :config
;;   (setq typepad-text-path (concat user-emacs-directory "misc/typepad"))
;;   (add-to-list 'meow-mode-state-list '(typepad-readonly-mode . motion))
;;   (typepad-load-long))

(provide 'init-typepad)
