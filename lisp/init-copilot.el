(use-package copilot
  :vc (:fetcher "github" :repo "zerolfx/copilot.el")
  :hook
  (emacs-lisp-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))

(provide 'init-copilot)
