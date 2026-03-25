(add-hook 'text-mode-hook #'my/setup-txt-imenu)
;; (use-package olivetti
;;   :ensure t
;;   :hook (text-mode . olivetti-mode)
;;   (prog-mode . olivetti-mode)
;;   :config
;;   (setq olivetti-body-width 100))
;; (use-package perfect-margin
;;   :hook
;;   (text-mode . perfect-margin-mode)
;;   (prog-mode . perfect-margin-mode))
;; ava in emacs>29
;; (use-package auto-scroll
;;   :init (slot/vc-install :fetcher "github" :repo "RJTK/emacs-auto-scroll"))
;;(add-to-list 'load-path "~/.emacs.d/site-lisp/auto-scroll")
;;(require 'auto-scroll)


(provide 'init-text)
