(use-package citre
  :ensure t
  :defer t
  :init
  ;; This is needed in `:init' block for lazy load to work.
  (require 'citre-config)
  ;; Bind your frequently used commands.  Alternatively, you can define them
  ;; in `citre-mode-map' so you can only use them when `citre-mode' is enabled.
  ;; :bind
  ;; (:prefix-map citre-mode-map
  ;;   :prefix "C-c l"
  ;;   ("p" . citre-peek)
  ;;   ("u" . citre-update-this-tags-file)
  ;;   ("j" . citre-jump))

  :config
  (define-prefix-command 'citre-prefix)
  (global-set-key (kbd "C-c f") 'citre-prefix)
  (define-key citre-prefix (kbd "p") 'citre-peek)
  (define-key citre-prefix (kbd "u") 'citre-update-this-tags-file)
  (define-key citre-prefix (kbd "j") 'citre-jump)
  (setq
   citre-ctags-program "/usr/bin/ctags"
   ;; Set this if you want to always use one location to create a tags file.
   citre-default-create-tags-file-location 'global-cache
   ;; See the "Create tags file" section above to know these options
   ;; citre-use-project-root-when-creating-tags t
   citre-prompt-language-for-ctags-command t
   ;; By default, when you open any file, and a tags file can be found for it,
   ;; `citre-mode' is automatically enabled.  If you only want this to work for
   ;; certain modes (like `prog-mode'), set it like this.
    citre-auto-enable-citre-mode-modes '(emacs-lisp-mode))
  (setq-default citre-enable-capf-integration nil
    citre-enable-xref-integration nil)
  (defvar citre-elisp-backend
    (citre-xref-backend-to-citre-backend
      'elisp
      (lambda () (derived-mode-p 'emacs-lisp-p))))
  (citre-register-backend 'elisp citre-elisp-backend)
  (setq citre-find-reference-backends '(elisp eglot global))
  (setq citre-find-definition-backends '(elisp eglot tags global))
  )


(provide 'init-tags)
