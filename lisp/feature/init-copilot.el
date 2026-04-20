(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el")
  :defer 2
  ;; :hook
  ;; (emacs-lisp-mode . copilot-mode)
  :config
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))

(use-package agent-shell
  :commands
  (agent-shell
   agent-shell-new-shell
   agent-shell-openai-start-codex
   agent-shell-anthropic-start-claude-code
   agent-shell-google-start-gemini)
  :bind
  (("C-c a" . agent-shell)
    ("C-c A" . agent-shell-openai-start-codex))
  :config
      (setq agent-shell-anthropic-authentication
          (agent-shell-anthropic-make-authentication
           :api-key ""))

    (setq agent-shell-anthropic-claude-environment
          (agent-shell-make-environment-variables
           "ANTHROPIC_BASE_URL" "https://api.kimi.com/coding/")))

(use-package gptel
  :straight (gptel :host github :repo "karthink/gptel")
;;  :defer t
  :config
  (setq-default gptel-default-mode 'org-mode)
  (setq kimi
    (gptel-make-anthropic "kimi"
      :host "api.kimi.com"
      :endpoint "/coding/v1/messages"
      :key 'gptel-api-key
      ;;:stream t
      :models '("kimi-for-coding"
                 "kimi-k2.5"
                "kimi-k2-0905-preview"
                "kimi-k2-thinking"
                "moonshot-v1-8k"
                "moonshot-v1-32k"
                "moonshot-v1-128k")))
  (setq-default gptel-backend kimi)
  (setq-default gptel-model 'kimi-for-coding))

(provide 'init-copilot)
