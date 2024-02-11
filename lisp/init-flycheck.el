(use-package flymake
  :elpaca nil
  :ensure nil
  :config
  (setq flymake-no-changes-timeout nil)
  (defun my/flymake ()
    (add-hook 'meow-insert-exit-hook
      (lambda ()
        (flymake-mode 1)
        (setq-local eglot-send-changes-idle-time 0.3)) nil t)
    (add-hook 'meow-insert-enter-hook
      (lambda ()
        (flymake-mode -1)
        (setq-local eglot-send-changes-idle-time 0)) nil t)))

;; (use-package flyspell
;;   :elpaca nil
;;   :ensure nil
;;   )

(use-package lazyflymake
  :elpaca (:host github :repo "redguardtoo/lazyflymake")
  :ensure nil
  :config
  (defun my/meow-flymake ()
    (interactive)
    (add-hook 'meow-insert-exit-hook 'lazyflymake-start nil t)
    (add-hook 'meow-insert-enter-hook 'lazyflymake-stop nil t)))


(provide 'init-flycheck)
