;; Enabling only some features
(setq dap-auto-configure-features '(sessions locals controls tooltip))

(require 'dap-mode)
(require 'dap-cpptools)
;; lsp-mode shoulde be enabled before dap

(provide 'init-dap)
