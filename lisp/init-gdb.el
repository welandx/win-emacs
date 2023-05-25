(use-package gdb-mi
  :bind
  (:map gud-mode-map
	("r" . gud-run)
	("n" . gud-next))
  :config
  (setq-default gdb-many-windows t))
(use-package realgud
  :defer t)
(provide 'init-gdb)
