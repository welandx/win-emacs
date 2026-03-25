(use-package flymake
  :ensure nil
  :config
  (setq flymake-no-changes-timeout nil)
  (defun my/flymake ()
    (interactive)
    (add-hook 'meow-insert-exit-hook
      (lambda ()
        (flymake-mode 1)
        (setq-local eglot-send-changes-idle-time 0)) nil t)
    (add-hook 'meow-insert-enter-hook
      (lambda ()
        (flymake-mode -1)
        (setq-local eglot-send-changes-idle-time 0)) nil t))
  (add-hook 'flymake-mode-hook #'my/flymake))

;; (use-package flyspell
;;   :ensure nil
;;   )

(use-package lazyflymake
  :straight (:host github :repo "redguardtoo/lazyflymake")
  :ensure nil
  :config
  (defun my/meow-flymake ()
    (interactive)
    (add-hook 'meow-insert-exit-hook 'lazyflymake-start nil t)
    (add-hook 'meow-insert-enter-hook 'lazyflymake-stop nil t)))


(provide 'init-flycheck)
