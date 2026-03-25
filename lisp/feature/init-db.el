;;; init-db.el --- Database tools  -*- lexical-binding: t; -*-

(use-package clutch
  :straight
  (clutch :type git :host github :repo "LuciusChen/clutch")
  :commands (clutch-query-console clutch-switch-console clutch-mode clutch-repl)
  :bind
  (("C-c d q" . clutch-query-console)
   ("C-c d s" . clutch-switch-console)
   ("C-c d r" . clutch-repl)))

(provide 'init-db)
;;; init-db.el ends here
