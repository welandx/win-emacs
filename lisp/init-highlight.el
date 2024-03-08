(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist '("cpp" "yaml" "rust"))
  (global-treesit-auto-mode)
  (setq treesit-font-lock-level 4))

(use-package rust-mode
  :ensure t)

(use-package markdown-mode
  :ensure t)

(use-package lua-mode
  :ensure t)

(use-package vimrc-mode
  :ensure t)

;; 在 org-src-block 使用 ts-mode 高亮
(with-eval-after-load 'org
  (defun my/remap-mode (mode)
    "make org-src-get-lang-mode respect major-mode-remap-alist"
    (treesit-auto--set-major-remap)
    (alist-get mode major-mode-remap-alist mode))
  (advice-add 'org-src-get-lang-mode :filter-return #'my/remap-mode))

(use-package highlight-defined
  :ensure t
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

(provide 'init-highlight)
