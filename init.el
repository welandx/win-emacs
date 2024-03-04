(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                          ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(add-to-list 'load-path "~/.emacs.d/lisp")
(defconst *is-a-win* (eq system-type 'windows-nt))
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))
(when (file-exists-p "~/.emacs.d/elpa/emacs-gc-stats-1.4.2")
  (add-to-list 'load-path "~/.emacs.d/elpa/emacs-gc-stats-1.4.2")
  (require 'emacs-gc-stats)
  (setq emacs-gc-stats-remind t)
  (emacs-gc-stats-mode +1))

(unless (bound-and-true-p my-computer-has-smaller-memory-p)
  (setq gc-cons-percentage 0.6)
  (setq gc-cons-threshold most-positive-fixnum))

(let* ((minver "29"))
  (when (version< emacs-version minver)
    (unless (package-installed-p 'use-package)
      (package-install "use-package"))))

;; 一些默认设置
(setq default-directory "~/")
(scroll-bar-mode 0)
;; (setq make-backup-files nil)
;; (setq auto-save-default nil)
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
(fset 'yes-or-no-p 'y-or-n-p)
(add-to-list 'load-path "~/.emacs.d/lisp")
(setq-default default-directory "~/")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)
(setq display-time-24hr-format t)
(display-time-mode 1)
(display-battery-mode 1)
(if *is-a-linux*
  (when
    (string=  "N/A"
      (cdr (car (battery-linux-sysfs))))
    (display-battery-mode -1)))
(setq lisp-indent-offset 2)
(setq-default indent-tabs-mode nil)

;; 加载 lib
(require 'init-lib)

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
(add-hook 'prog-mode-hook 'electric-pair-local-mode)
(add-hook 'conf-mode-hook 'electric-pair-local-mode)
(use-package company
  :ensure t
  :hook
  ;; (prog-mode . company-mode)
  (org-mode . company-mode)
  (text-mode . company-mode)
  :config
  (define-key company-active-map (kbd "TAB") nil)
  (define-key company-active-map [tab] nil)
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map [tab] 'company-complete-selection)
  (define-key company-active-map (kbd "M-n") 'company-complete-selection)
  (define-key company-active-map [return] nil)
  (define-key company-active-map (kbd "RET") nil))
;; (use-package fussy
;;   :ensure t
;;   :config
;;   (push 'fussy completion-styles)
;;   (setq
;;    ;; For example, project-find-file uses 'project-files which uses
;;    ;; substring completion by default. Set to nil to make sure it's using
;;    ;; flx.
;;    completion-category-defaults nil
;;    completion-category-overrides nil))

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
  :disabled
  :ensure t
  :config
  (ace-pinyin-global-mode +1))
(use-package avy
  :bind
  (:map meow-normal-state-keymap
        ("F" . avy-goto-char)))
(use-package ace-window
  :ensure t
  :init
  (require 'ace-window)
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
(use-package super-save
  :ensure t
  :config
  (super-save-mode +1))
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))
(use-package fontawesome
  :ensure t)
(use-package nerd-icons
  :ensure t
  :defer 1
  :config
  (when (and *is-a-mac* (member "Symbols Nerd Font Mono" (font-family-list)))
    (setq nerd-icons-font-family "Symbols Nerd Font Mono"))
  (when (and *is-a-win* (member "FantasqueSansM Nerd Font Mono" (font-family-list)))
    (setq nerd-icons-font-family "FantasqueSansM Nerd Font Mono")))
(use-package yasnippet
  :ensure t
  ;; :bind
  ;; (:map org-mode-map
  ;;       ("M-/" . yas-expand))
  :config
  (yas-global-mode 1))
(use-package recentf
  :ensure nil
  :defer 0.1
  :bind
  ("C-c o" . recentf-open)
  :init
  (setq recentf-max-saved-items 1000)
  (setq recentf-exclude '("/tmp/" "/ssh:"))
  (recentf-mode 1))
(global-set-key (kbd "<f9>") 'toggle-one-window)
(global-set-key (kbd "<f8>") 'scratch-buffer)
(global-set-key (kbd "C-c n") 'revert-buffer)

;; windows
(when *is-a-win*
  ;; (set-frame-font "FantasqueSansM Nerd Font Mono-16")
  ;; (set-fontset-font t 'han "微软雅黑-13")
  (set-fontset-font t 'han "霞鹜文楷 屏幕阅读版")
  ;; (load-theme 'yoshi t)
  ;; (load-theme 'wheatgrass t)
  (load-theme 'ef-melissa-light t)
  (require 'init-gbk)
  (require-init 'init-win)
  (setq org-directory "~/notes")
  )
;; Mac OS
(when *is-a-mac*
  ;; (when (member "Menlo" (font-family-list))
  ;;   (set-frame-font "MonoLisa Nasy-15" t t))
  ;; (set-fontset-font "fontset-default" 'unicode "SF Pro")
  ;; (set-fontset-font "fontset-default" 'emoji "Apple Color Emoji")
  (setq-default org-directory "~/notes")
  (require-init 'init-telega)
  (load-theme 'modus-vivendi t)
  ;;(require-init 'init-theme)
  (require 'init-mac-org)
  (require-init 'init-osx-keys)
  (require-init 'init-exec-path)
  )
;; GNU/Linux
(when *is-a-linux*
  (setq-default org-directory "~/notes")
  ;; (load-theme 'ef-elea-dark t)
  ;; (load-theme 'modus-operandi-tinted t)
  (use-package kanagawa-theme
    :ensure t
    :demand
    ;; :config
    ;; (load-theme 'kanagawa t)
    )
  (load-theme 'nier t)
    (require-init 'init-telega))

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
(require-init 'init-fonts)
(require-init 'init-private)
(require-init 'init-news)
(require-init 'init-highlight)
(require-init 'init-dict)
(run-with-idle-timer 2 nil
  (lambda ()
    (require-init 'init-copilot)))
(require-init 'init-tab)
(require-init 'init-tags)

(use-package keyfreq
  :ensure t
  :config
  (setq keyfreq-excluded-commands '(self-insert-command
                                     pixel-scroll-precision
                                     meow-keypad
                                     org-self-insert-command
                                     meow-left
                                     backward-delete-char-untabify
                                     meow-next
                                     meow-prev
                                     mouse-set-point
                                     meow-insert-exit
                                     meow-right
                                     meow-keypad-self-insert
                                     mouse-drag-region
                                     org-delete-backward-char
                                     meow-insert
                                     delete-backward-char))
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

(setq-default

  warning-suppress-log-types '((comp))

  ;; Backup setups
  ;; We use temporary directory /tmp for backup files
  ;; More versions should be saved
  backup-directory-alist `((".*" . ,temporary-file-directory))
  auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
  backup-by-copying t
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t

  ;; Don't wait for keystrokes display
  echo-keystrokes 0.01

  ;; Disable margin for overline and underline
  overline-margin 0
  underline-minimum-offset 0

  ;; Better scroll behavior
  mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
  mouse-wheel-progressive-speed nil

  ;; Disable copy region blink
  copy-region-blink-delay 0

  ;; Use short answer when asking yes or no
  read-answer-short t

  ;; Mouse yank at current point
  mouse-yank-at-point t

  ;; DWIM target for dired
  ;; Automatically use another dired buffer as target for copy/rename
  dired-dwim-target t

  ;; Don't echo multiline eldoc
  eldoc-echo-area-use-multiline-p nil)

(global-subword-mode 1)

(global-set-key (kbd "C-'") 'set-mark-command)

(when *is-a-linux*
  (require-init 'init-pyim)
  (require-init 'init-typepad))

(setq show-paren-delay 0.02)

(add-to-list 'auto-mode-alist '("\\Eask\\'" . lisp-mode))

(with-eval-after-load 'org-agenda
  (add-hook 'org-agenda-mode-hook 'hl-line-mode))

(require-init 'init-corfu)
(require-init 'init-flycheck)
(require-init 'init-lsp)
(require-init 'init-popper)

(use-package winner
  :ensure nil
  :config
  (winner-mode))

(use-package psearch
  :straight (:host github :repo "twlz0ne/psearch.el")
  ;; :config
  ;; (psearch-patch rotate:refresh-window
  ;;   (psearch-replace '`(not (one-window-p))
  ;;     '`(not (eq 2 (length (window-list)))))
  ;;   (psearch-replace '`(window-num (count-windows))
  ;;     '`(window-num (1- (count-windows))))))
  )

(defun append-to-list (list-var elements)
  "Append ELEMENTS to the end of LIST-VAR.

The return value is the new value of LIST-VAR."
  (unless (consp elements)
    (error "ELEMENTS must be a list"))
  (let ((list (symbol-value list-var)))
    (if list
        (setcdr (last list) elements)
      (set list-var elements)))
  (symbol-value list-var))
(use-package rainbow-mode
  :ensure t
  ;; :init
  ;; (add-to-list 'auto-mode-alist '("\\theme.el\\'" . rainbow-mode))
  :config
  (append-to-list 'rainbow-r-colors-alist
    '(("ng1" . "#404040")
       ("ng2" . "#787466")
       ("ng3" . "#686458")
       ("ng4" . "#5e6666")
       ("ng5" . "#50403c")
       ("ng6" . "#4e4c43")
       ("ns1" . "#dad4bb")
       ("ns2" . "#cac4ad")
       ("ns3" . "#b9b49f")
       ("ns4" . "#a9a491")
       ("ns5" . "#999482")
       ("ns6" . "#898474")
       ("na1" . "#cd664d")
       ("na2" . "#b4af9a")
       ("na3" . "#3ba99f")
       ("na4" . "#727b59")
       ("na5" . "#b26f5f")
       ("yorha-0" . "#f9f5d7")
       ("yorha-1" . "#9d0006")
       ("yorha-2" . "#79740e")
       ("yorha-3" . "#b57614")
       ("yorha-4" . "#076678")
       ("yorha-5" . "#8f3f71")
       ("yorha-6" . "#427b58")
       ("yorha-7" . "#504945")
       ("yorha-8" . "#bdae93")
       ("yorha-9" . "#282828")
       ("yorha-bg" . "#c2bda6")
       ("yorha-fg" . "#48463d")
       ("yorha-cursor" . "#f4f0e1")
       ))
  (setq rainbow-r-colors t))
;; (add-to-list 'load-path "~/.emacs.d/site-lisp/nier")
;; (require 'nier-theme)

(use-package nov
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  :config
  (add-hook 'nov-mode-hook (lambda () (setq truncate-lines t))))

(setq vc-follow-symlinks t)

(add-to-list 'load-path "~/.emacs.d/site-lisp/auto-scroll")
(require 'auto-scroll)


;; =============
;; Init End Here
;; =============

(defun my-cleanup-gc ()
  "Clean up gc."
  (setq gc-cons-threshold  67108864) ; 64M
  (setq gc-cons-percentage 0.1) ; original value
  (garbage-collect))

(run-with-idle-timer 4 nil #'my-cleanup-gc)

;; startup done
(run-with-timer 0.2 nil
  (lambda ()
    (message "*** Emacs loaded in %s with %d garbage collections."
      (format "%.2f seconds"
        (float-time (time-subtract after-init-time before-init-time)))
      gcs-done)))


(add-hook 'window-setup-hook
  (lambda ()
    (when (not window-system)
      (load-theme 'modus-vivendi t)
      (set-background-color "nil"))))
(put 'erase-buffer 'disabled nil)
(put 'list-timers 'disabled nil)
