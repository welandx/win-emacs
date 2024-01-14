(add-to-list 'load-path (concat user-emacs-directory "site-lisp/TypePad"))

(require 'typepad)

(setq typepad-text-path (concat user-emacs-directory "site-lisp/TypePad/top500.txt"))

;; enable visual-fill-column-mode in typepad-mode and typepad-readonly-mode
(add-hook 'typepad-mode-hook 'visual-fill-column-mode)
(add-hook 'typepad-readonly-mode-hook 'visual-fill-column-mode)


