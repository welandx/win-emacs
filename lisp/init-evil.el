(use-package evil
  :ensure t
  :init (progn
          (setq evil-want-integration nil)
          )
  :config
  (evil-mode)
  (evil-define-key 'normal global-map (kbd "s") 'avy-goto-char))

(use-package evil-collection
  :disabled
  :ensure t)

(use-package god-mode
  :ensure t)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package evil-god-state
  :ensure t
  :after (god-mode evil)
  :config (progn
            ;; 按空格进入evil-god-state
            (evil-define-key 'normal global-map (kbd "SPC") 'evil-execute-in-god-state)
            (evil-define-key 'god global-map (kbd "<escape>") 'evil-god-state-bail)
            (with-eval-after-load 'which-key
              (which-key-enable-god-mode-support))))

(global-set-key (kbd "C-x C-1") 'delete-other-windows)
(global-set-key (kbd "C-x C-2") 'split-window-below)
(global-set-key (kbd "C-x C-3") 'split-window-right)
