(use-package copilot
  :elpaca nil
  :vc (:fetcher "github" :repo "zerolfx/copilot.el")
  :defer 1
  ;; :hook
  ;; (emacs-lisp-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))


(use-package gptel
  :elpaca (gptel :host github :repo "karthink/gptel") ;;downloaded from github
  ;; :vc (:fetcher "github" :repo "karthink/gptel")
  :defer 1
  :config
  (setq-default gptel-default-mode 'org-mode)
  (setq gpt-liaobot
    (gptel-make-openai "liaobot"
      :host "ai.liaobots.work"
      :protocol "https"
      :endpoint "/v1/chat/completions"
      :header (lambda () `(("Authorization" . ,(concat "Bearer " (gptel--get-api-key)))))
      :key 'gptel-api-key
      :stream t
      :models '("gpt-3.5-turbo" "gpt-3.5-turbo-16k")))
  (setq openai-api
    (gptel-make-openai "openai-api"
      :host "api.chatanywhere.tech"
      :protocol "https"
      :endpoint "/v1/chat/completions"
      :header (lambda () `(("Authorization" . ,(concat "Bearer " (gptel--get-api-key)))))
      :key 'gptel-api-key
      :stream t
      :models '("gpt-3.5-turbo" "gpt-3.5-turbo-16k")))
  (setq-default gptel-backend gpt-liaobot))

(provide 'init-copilot)
