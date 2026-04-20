(use-package eglot
  :straight nil
  :hook
  (python-mode . eglot-ensure)
  (c++-mode . eglot-ensure)
  (c++-ts-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  (js-ts-mode . eglot-ensure)
  (typescript-ts-mode . eglot-ensure)
  (tsx-ts-mode . eglot-ensure)
  (vue-ts-mode . eglot-ensure)
  :bind
  (:prefix-map eglot-map
    :prefix "C-c l"
    ("f" . eglot-format))
  :config
  (add-to-list 'eglot-server-programs
               '(vue-ts-mode . ("vue-language-server" "--stdio"))))

(provide 'init-lsp)
