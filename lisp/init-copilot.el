(use-package copilot
  :vc (:fetcher "github" :repo "zerolfx/copilot.el")
  :defer 1
  ;; :hook
  ;; (emacs-lisp-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))

(use-package markdown-mode
  :ensure t)
(use-package gptel
  :vc (:fetcher "github" :repo "karthink/gptel")
  :defer 1
  :config
  (setq-default gptel-backend
    (gptel-make-openai "openai-api"
      :host "api.chatanywhere.tech"
      :protocol "https"
      :endpoint "/v1/chat/completions"
      :header (lambda () `(("Authorization" . ,(concat "Bearer " (gptel--get-api-key)))))
      :key 'gptel-api-key
      :stream t
      :models '("gpt-3.5-turbo" "gpt-3.5-turbo-16k"))))

(provide 'init-copilot)
