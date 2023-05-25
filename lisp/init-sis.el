(use-package sis
  ;; :hook
  ;; enable the /context/ and /inline region/ mode for specific buffers
  ;; (((text-mode prog-mode) . sis-context-mode)
  ;;  ((text-mode prog-mode) . sis-inline-mode))

  :config
  (sis-ism-lazyman-config nil t 'w32)

  ;; enable the /cursor color/ mode
  (sis-global-cursor-color-mode t)
  ;; enable the /respect/ mode
  ;;(sis-global-respect-mode t)
  ;; enable the /context/ mode for all buffers
  (sis-global-context-mode t)
  ;; enable the /inline english/ mode for all buffers
  (sis-global-inline-mode t)
  )

  (with-eval-after-load 'sis
    (add-hook 'meow-insert-exit-hook #'sis-set-english)
    (add-to-list 'sis-context-hooks 'meow-insert-enter-hook))

(provide 'init-sis)
