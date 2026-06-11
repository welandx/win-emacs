(setq treesit-font-lock-level 4)

(defun my/treesit-ready-p (lang)
  "Return non-nil when LANG grammar is available for tree-sitter."
  (and (fboundp 'treesit-ready-p)
       (treesit-ready-p lang t)))

(when (my/treesit-ready-p 'cpp)
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode)))

(when (my/treesit-ready-p 'yaml)
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode)))

(when (my/treesit-ready-p 'rust)
  (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode)))

(use-package rust-mode
  )

(use-package markdown-mode
  :hook (markdown-mode . valign-mode))

(use-package lua-mode
  )

(use-package vimrc-mode
  )

(use-package yaml-mode
  )

;; 在 org-src-block 使用 ts-mode 高亮
(with-eval-after-load 'org
  (defun my/remap-mode (mode)
    "make org-src-get-lang-mode respect major-mode-remap-alist"
    (alist-get mode major-mode-remap-alist mode))
  (advice-add 'org-src-get-lang-mode :filter-return #'my/remap-mode))

(use-package highlight-defined
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

(provide 'init-highlight)
