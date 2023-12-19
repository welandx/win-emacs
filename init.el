(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(unless (bound-and-true-p package--initialized)
  (setq package-enable-at-startup nil)
  (package-initialize))

(let* ((minver "29"))
  (when (version< emacs-version minver)
    (unless (package-installed-p 'use-package)
      (package-install "use-package"))))
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-win* (eq system-type 'windows-nt))

;; 一些默认设置
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
(setq-default frame-title-format "Weland Emacs")
(set-window-scroll-bars (minibuffer-window) nil nil)
(setq-default cursor-in-non-selected-windows nil)
(setq word-wrap-by-category t)
(toggle-word-wrap)
(setq byte-compile-warnings nil)
(setq shr-max-image-proportion 0.7) ;;限制 image 大小
(setq confirm-kill-processes nil)
;; 一些默认 package
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
      (load-theme 'modus-operandi-tritanopia t))))
(electric-pair-mode 1)
(use-package company
  :ensure t
  :config
  (global-company-mode 1))
(use-package fussy
  :ensure t
  :config
  (push 'fussy completion-styles)
  (setq
   ;; For example, project-find-file uses 'project-files which uses
   ;; substring completion by default. Set to nil to make sure it's using
   ;; flx.
   completion-category-defaults nil
   completion-category-overrides nil))
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
(setq display-time-24hr-format t)
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
  :ensure t
  :bind
  ("C-c r" . ripgrep-regexp))
(use-package rotate
  :ensure t
  :bind
  ("C-c z" . rotate-layout))
(use-package ef-themes
  :ensure t)
(let* ((minver "29"))
  (unless (version< emacs-version minver)
    (pixel-scroll-precision-mode 1)))
(setq-default cursor-in-non-selected-windows nil)
(fset 'yes-or-no-p 'y-or-n-p)
(use-package super-save
  :ensure t
  :config
  (super-save-mode +1))

;; extra
(cond
 ((string-equal system-type "windows-nt")
  (progn
    (set-frame-font "Consolas-16")
    (set-fontset-font t 'han "微软雅黑-13")
    (load-theme 'yoshi t)
    (require 'init-gbk)
    (require-init 'init-win)
    )))
(require-init 'init-sis)
(require-init 'init-org)
(require-init 'init-whitespace)
(require-init 'init-gdb)
(require-init 'init-text)
(require-init 'init-git)
(require-init 'init-modeline)
(require-init 'init-scroll)
(require-init 'init-ibuffer)
(require-init 'init-dired)
(use-package fontawesome
  :ensure t)
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; Mac OS
(when *is-a-mac*
  ;; (when (member "Menlo" (font-family-list))
  ;;   (set-frame-font "MonoLisa Nasy-15" t t))
  ;; (set-fontset-font "fontset-default" 'unicode "SF Pro")
  ;; (set-fontset-font "fontset-default" 'emoji "Apple Color Emoji")
  (require-init 'init-fonts)
  (setq-default org-directory "~/Documents/org")
  (require-init 'init-telega)
  (require-init 'init-theme)
  (require-init 'init-osx-keys)
  (require-init 'init-exec-path))

(use-package elfeed
  :ensure t
  :bind
  ("C-c e" . elfeed))
(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))
(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist '("cpp"))
  (global-treesit-auto-mode)
  (setq treesit-font-lock-level 4))

(use-package hl-defined
  ;; 高亮 emacs-lisp function
  :load-path "./site-lisp/hl-defined"
  :config
  (add-hook 'emacs-lisp-mode-hook 'hdefd-highlight-mode 'APPEND))



