(use-package copilot
  :vc (:fetcher "github" :repo "zerolfx/copilot.el")
  :defer 1
  ;; :hook
  ;; (emacs-lisp-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))

(provide 'init-copilot)
