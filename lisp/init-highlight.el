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

;; 在 org-src-block 使用 ts-mode 高亮
(with-eval-after-load 'org
  (defun my/remap-mode (mode)
    "make org-src-get-lang-mode respect major-mode-remap-alist"
    (treesit-auto--set-major-remap)
    (alist-get mode major-mode-remap-alist mode))
  (advice-add 'org-src-get-lang-mode :filter-return #'my/remap-mode))


(provide 'init-highlight)
