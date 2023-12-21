(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist '("cpp" "yaml"))
  (global-treesit-auto-mode)
  (setq treesit-font-lock-level 4))

(use-package hl-defined
  ;; 高亮 emacs-lisp function
  :load-path "./site-lisp/hl-defined"
  :config
  (add-hook 'emacs-lisp-mode-hook 'hdefd-highlight-mode 'APPEND))

(provide 'init-highlight)
