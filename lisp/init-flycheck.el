(use-package flymake
  :elpaca nil
  :ensure nil
  :hook
  (meow-insert-exit-hook . flymake-mode-on)
  (meow-insert-enter-hook . flymake-mode-off))
