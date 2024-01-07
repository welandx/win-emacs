(use-package magit
  :ensure t
  :bind
  ("C-c v" . magit))

(use-package diff-hl
  :defer 0.1
  :ensure t
  :config
  (global-diff-hl-mode))

(provide 'init-git)
