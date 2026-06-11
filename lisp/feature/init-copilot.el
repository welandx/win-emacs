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
  :bind ("C-c g" . gptel-menu)
;;  :defer t
  :config
  (require 'gptel-integrations)
  (setq-default gptel-default-mode 'org-mode)
  (setq volcengine-coding
    (gptel-make-openai "volcengine-coding"
      :host "ark.cn-beijing.volces.com"
      :endpoint "/api/coding/v3/chat/completions"
      :key 'gptel-api-key
      :stream t
      :models '("ark-code-latest"
                "doubao-seed-code-preview-latest"
                "deepseek-v4-pro"
                "deepseek-v4-flash"
                "glm-5.1"
                "kimi-k2.6")))
  (setq-default gptel-backend volcengine-coding)
  (setq-default gptel-model 'ark-code-latest)

  (defun weland-gptel-block-missing-tool-args (tool-call)
    "Block gptel TOOL-CALLs that omit required tool arguments."
    (when-let* ((name (plist-get tool-call :name))
                (args (plist-get tool-call :args))
                (tool (cl-find name gptel-tools
                               :key #'gptel-tool-name :test #'equal))
                (missing
                 (cl-loop for arg in (gptel-tool-args tool)
                          for arg-name = (plist-get arg :name)
                          for key = (intern (concat ":" arg-name))
                          unless (or (plist-get arg :optional)
                                     (and (plist-member args key)
                                          (plist-get args key)))
                          collect arg-name)))
      (when missing
        (let ((message (format "Tool %s missing required argument%s: %s"
                               name
                               (if (cdr missing) "s" "")
                               (string-join missing ", "))))
          (message "%s" message)
          (list :block message)))))

  (add-hook 'gptel-pre-tool-call-functions
            #'weland-gptel-block-missing-tool-args))

(defun weland-tavily-api-key ()
  "Return the Tavily API key from the environment or auth-source."
  (or (getenv "TAVILY_API_KEY")
      (auth-source-pick-first-password :host "tavily.com")
      ""))

(use-package mcp
  :straight (:host github :repo "lizqwerscott/mcp.el")
  :after gptel
  :commands (mcp-hub mcp-hub-start-all-server)
  :init
  (setq mcp-hub-servers
        `(("tavily" . (:command "npx"
                       :args ("-y" "tavily-mcp")
                       :timeout 60
                       :env (:TAVILY_API_KEY ,(weland-tavily-api-key))))))
  :config
  (require 'mcp-hub))

(defvaralias 'weland-codex-ide-font-families
  'weland-sarasa-buffer-font-families)
(defalias 'weland-codex-ide-font-family #'weland-sarasa-buffer-font-family)
(defalias 'weland-codex-ide-clear-stale-composition
  #'weland-sarasa-buffer-clear-stale-composition)
(defalias 'weland-codex-ide-use-sarasa-font #'weland-buffer-use-sarasa-font)
(defalias 'weland-codex-ide-use-fonts #'weland-codex-ide-use-sarasa-font)

(defun weland-codex-ide-enable-rime ()
  "Enable Rime input method in codex-ide buffers."
  (when *is-a-mac*
    (activate-input-method "rime")))

(use-package codex-ide
  :straight (:type git :host github :repo "dgillis/emacs-codex-ide")
  :hook ((codex-ide-session-mode . weland-codex-ide-use-sarasa-font)
         (codex-ide-session-mode . weland-codex-ide-enable-rime))
  :bind ("C-c C-;" . codex-ide-menu))

(provide 'init-copilot)
