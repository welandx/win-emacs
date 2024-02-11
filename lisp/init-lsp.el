(use-package eglot
  :elpaca nil
  :ensure nil
  :hook
  (python-mode . eglot-ensure)
  (c++-mode . eglot-ensure)
  (c++-ts-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  :bind
  (:prefix-map eglot-map
    :prefix "C-c l"
    ("f" . eglot-format))
  :config
  ;; (setq eglot-send-changes-idle-time 0)
  )

(provide 'init-lsp)
