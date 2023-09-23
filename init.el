(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)
(use-package emacs-gc-stats
  :ensure t
  :config
  ;; Optionally disable logging the command names
  ;; (setq emacs-gc-stats-inhibit-command-name-logging t)
  (setq emacs-gc-stats-gc-defaults 'emacs-defaults)
  (setq emacs-gc-stats-remind t) ; can also be a number of days
  (emacs-gc-stats-mode +1))

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
(setq-default frame-title-format "Weland Emacs")
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
      (load-theme 'modus-operandi-tritanopia t))))
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
  :ensure t)
(let* ((minver "29"))
  (unless (version< emacs-version minver)
    (pixel-scroll-precision-mode 1)))
(setq-default cursor-in-non-selected-windows nil)

;; extra
(cond
 ((string-equal system-type "windows-nt")
  (progn
    (set-frame-font "Consolas-16")
    (set-fontset-font t 'han "微软雅黑-13")
    (load-theme 'yoshi t)
    (require 'init-gbk)
    (require-init 'init-win)
    (require-init 'init-sis))))

(require-init 'init-whitespace)
(require-init 'init-gdb)
(require-init 'init-text)
(require-init 'init-git)
(require-init 'init-modeline)
(require-init 'init-scroll)
(require-init 'init-ibuffer)
(require-init 'init-dired)


;; Mac OS
(defconst *is-a-mac* (eq system-type 'darwin))
(when *is-a-mac*
  (when (member "Menlo" (font-family-list))
    (set-frame-font "Menlo-14" t t))
  (setq-default org-directory "~/Documents/org")
  (require-init 'init-telega)
  (require-init 'init-osx-keys)
  (require-init 'init-exec-path))
