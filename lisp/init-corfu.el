(use-package corfu
  :ensure t
  :hook ((prog-mode . corfu-mode)
          (shell-mode . corfu-mode)
          (eshell-mode . corfu-mode))
  :bind
  (:map corfu-map
    ("SPC" . corfu-insert-separator)
    ("C-<return>" . newline))

  :config
  (setq corfu-auto t)
  (setq  completion-styles '(orderless basic)))

(setq completion-cycle-threshold 3)

(setq tab-always-indent 'complete)

(use-package nerd-icons-corfu
  :after corfu)

(provide 'init-corfu)
