(use-package magit
  :ensure t
  :bind
  ("C-c v" . magit))

(use-package diff-hl
  :defer 0.1
  :ensure t
  :hook
  (dired-mode . diff-hl-dired-mode)
  :config
  (global-diff-hl-mode))

(provide 'init-git)
