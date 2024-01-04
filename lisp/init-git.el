(use-package magit
  :ensure t
  :bind
  ("C-c v" . magit))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode))

(provide 'init-git)
