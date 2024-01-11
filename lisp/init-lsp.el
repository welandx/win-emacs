(use-package eglot
  :hook
  (python-mode . eglot-ensure)
  :bind
  (:prefix-map eglot-map
    :prefix "C-c l"
    ("f" . eglot-format)))

(provide 'init-lsp)
