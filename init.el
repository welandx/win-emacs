(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)
(let* ((minver "29"))
  (when (version< emacs-version minver)
    (unless (package-installed-p 'use-package)
      (package-install "use-package"))))
(setq default-directory "~/")
(menu-bar-mode 0)
(tool-bar-mode -1)
(scroll-bar-mode 0)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(set-window-scroll-bars (minibuffer-window) nil nil)
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))
(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))
(let* ((minver "29"))
  (when (version< emacs-version minver)
    (use-package modus-themes
      :ensure t
      :config
      (load-theme 'modus-operandi-tinted t))))
(electric-pair-mode 1)
(use-package company
  :ensure t
  :config
  (global-company-mode 1))
(add-to-list 'load-path "~/.emacs.d/lisp")
(require 'init-lib)
(use-package meow
  :ensure t
  :init
  (require 'init-meow)
  :config
  (meow-setup)
  (meow-global-mode 1))
(use-package embark
  :ensure t
  :bind
  ("C-," . embark-act))
(setq-default default-directory "~/")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)
(display-time-mode 1)
(display-battery-mode 1)
(use-package saveplace
  :ensure nil
  :hook
  (text-mode . save-place-mode))
(use-package isearch
  :ensure nil
  :bind (:map isearch-mode-map
              ([remap isearch-delete-char] . isearch-del-char))
  :custom
  (isearch-lazy-count t)
  (lazy-count-prefix-format "%s/%s ")
  (lazy-highlight-cleanup nil))
(use-package imenu
  :bind
  ("C-'" . imenu))
(use-package ace-pinyin
  :ensure t
  :config
  (ace-pinyin-global-mode +1))
(use-package avy
  :bind
  (:map meow-normal-state-keymap
	("F" . avy-goto-char)))
(use-package ace-window
  :ensure t
  :bind
  ("C-c w" . ace-window))
(use-package consult
  :ensure t
  :bind
  ("C-c b" . consult-buffer))
(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode))
(use-package ripgrep
  :ensure t)
(let* ((minver "29"))
  (unless (version< emacs-version minver)
    (pixel-scroll-precision-mode 1)))


;; extra
(cond
 ((string-equal system-type "windows-nt")
  (progn
    (set-frame-font "Consolas-12")
    (set-fontset-font t 'han "微软雅黑")
    (require 'init-gbk)
    (require-init 'init-win)
    (require-init 'init-sis))))

(require-init 'init-whitespace)
(require-init 'init-gdb)
(require-init 'init-text)
(require-init 'init-git)
(require-init 'init-modeline)
