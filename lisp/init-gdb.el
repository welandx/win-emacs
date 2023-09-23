(use-package gdb-mi
  :bind
  (:map gud-mode-map
	("r" . gud-run)
	("n" . gud-next))
  :config
  (setq-default gdb-many-windows t))
;; gdb-mi can set bp when debugged program is running in emacs30
(use-package realgud
  :defer t)
(provide 'init-gdb)
