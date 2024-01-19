(add-to-list 'load-path (concat user-emacs-directory "site-lisp/TypePad"))
(add-to-list 'load-path (concat user-emacs-directory "site-lisp/TypePad/buffer-focus-hook"))

(require 'typepad)

(setq typepad-text-path (concat user-emacs-directory "site-lisp/TypePad/txt"))

(typepad-load-long)

;; enable visual-fill-column-mode in typepad-mode and typepad-readonly-mode
(add-hook 'typepad-mode-hook 'visual-fill-column-mode)
(add-hook 'typepad-readonly-mode-hook 'visual-fill-column-mode)

(use-package visual-fill-column
  :custom
  (visual-fill-column-center-text t)
  (visual-fill-column-width 100)
  ;; :hook
  ;; (prog-mode . visual-fill-column-mode)
  ;; (magit-mode . visual-fill-column-mode)
  )

(provide 'init-typepad)
