(use-package corfu
  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode)
         (mu4e-compose-mode . corfu-mode))
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-<return>" . newline))
  :config
  (setq corfu-auto t)
  (setq corfu-quit-no-match t)
  (setq corfu-auto-delay 0.1)
  (setq completion-styles '(orderless basic)))
(setq completion-cycle-threshold 3)

(setq tab-always-indent 'complete)

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))


(provide 'init-corfu)
