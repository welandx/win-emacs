;;; init.el --- Main init entrypoint  -*- lexical-binding: t; -*-

(defconst *is-a-win* (eq system-type 'windows-nt))
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))

(dolist (dir '("lisp" "lisp/core" "lisp/platform" "lisp/feature"))
  (add-to-list 'load-path (expand-file-name dir user-emacs-directory)))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)
(straight-use-package 'use-package)
(require 'use-package)

(require 'init-lib)

(setq-default
 default-directory "~/"
 create-lockfiles nil
 inhibit-startup-screen t
 ring-bell-function 'ignore
 frame-title-format "Weland Emacs"
 word-wrap-by-category t
 byte-compile-warnings nil
 confirm-kill-processes nil
 warning-suppress-log-types '((comp))
 display-time-24hr-format t
 backup-directory-alist `((".*" . ,temporary-file-directory))
 auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
 backup-by-copying t
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t
 echo-keystrokes 0.01
 overline-margin 0
 underline-minimum-offset 0
 mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
 mouse-wheel-progressive-speed nil
 copy-region-blink-delay 0
 read-answer-short t
 mouse-yank-at-point t
 dired-dwim-target t
 eldoc-echo-area-use-multiline-p nil
 lisp-indent-offset 2
 indent-tabs-mode nil
 shr-max-image-proportion 0.7
 custom-file (expand-file-name "custom.el" user-emacs-directory))

(unless (bound-and-true-p my-computer-has-smaller-memory-p)
  (setq gc-cons-percentage 0.6)
  (setq gc-cons-threshold most-positive-fixnum))

(set-window-scroll-bars (minibuffer-window) nil nil)
(toggle-word-wrap)
(fset 'yes-or-no-p 'y-or-n-p)
(load custom-file t)
(display-time-mode 1)
(display-battery-mode 1)

(when (and *is-a-linux*
           (string= "N/A" (cdr (car (battery-linux-sysfs)))))
  (display-battery-mode -1))

(use-package vertico
  :config
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package embark
  :bind
  ("C-," . embark-act))

(use-package saveplace
  :straight nil
  :hook
  (text-mode . save-place-mode))

(use-package isearch
  :straight nil
  :bind (:map isearch-mode-map
              ([remap isearch-delete-char] . isearch-del-char))
  :custom
  (isearch-lazy-count t)
  (lazy-count-prefix-format "%s/%s ")
  (lazy-highlight-cleanup nil))

(use-package imenu
  :straight nil
  :bind
  ("C-'" . imenu))

(use-package avy)

(use-package ace-window
  :bind
  ("C-c w" . ace-window))

(use-package consult
  :bind
  ("C-c b" . consult-buffer))

(use-package autorevert
  :straight nil
  :hook
  (after-init . global-auto-revert-mode))

(use-package ripgrep
  :bind
  ("C-c r" . ripgrep-regexp))

(use-package rotate
  :bind
  ("C-c z" . rotate-layout))

(use-package ef-themes
  :config
  (load-theme 'ef-day t))

(use-package super-save
  :config
  (super-save-mode +1))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package nerd-icons
  :defer 1
  :config
  (when (and *is-a-mac* (member "Symbols Nerd Font Mono" (font-family-list)))
    (setq nerd-icons-font-family "Symbols Nerd Font Mono"))
  (when (and *is-a-win* (member "FantasqueSansM Nerd Font Mono" (font-family-list)))
    (setq nerd-icons-font-family "FantasqueSansM Nerd Font Mono")))

(use-package yasnippet
  :init
  (setq yas-snippet-dirs
        (list (expand-file-name "snippets" user-emacs-directory))
        yas-trigger-key "TAB")
  :config
  (yas-reload-all)
  (yas-global-mode 1)
  (define-key yas-minor-mode-map (kbd "C-c y") #'yas-expand-from-trigger-key))

(use-package recentf
  :straight nil
  :defer 0.1
  :bind
  ("C-c o" . recentf-open)
  :init
  (setq recentf-max-saved-items 1000)
  (setq recentf-exclude '("/tmp/" "/ssh:"))
  (recentf-mode 1))

(global-set-key (kbd "<f9>") #'toggle-one-window)
(global-set-key (kbd "<f8>") #'scratch-buffer)
(global-set-key (kbd "C-c n") #'revert-buffer)
(global-set-key (kbd "C-'") #'set-mark-command)

(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'conf-mode-hook #'electric-pair-local-mode)

(when *is-a-win*
  (set-fontset-font t 'han "霞鹜文楷 屏幕阅读版")
  (setq org-directory "~/notes")
  (require-platform-module 'init-gbk)
  (require-platform-module 'init-win))

(when *is-a-mac*
  (setq-default org-directory "~/notes")
  (require-platform-module 'init-osx-keys)
  (require-platform-module 'init-exec-path))

(when *is-a-linux*
  (setq-default org-directory "~/notes")
  (require-platform-module 'init-pyim)
  (require-platform-module 'init-typepad))

(require-core-module 'init-evil)
(require-core-module 'init-modeline)
(require-core-module 'init-scroll)
(require-core-module 'init-fonts)

(require-feature-module 'init-whitespace)
(require-feature-module 'init-gdb)
(require-feature-module 'init-org)
(require-feature-module 'init-text)
(require-feature-module 'init-db)
(require-feature-module 'init-git)
(require-feature-module 'init-ibuffer)
(require-feature-module 'init-dired)
(require-feature-module 'init-highlight)
(require-feature-module 'init-dict)
(require-feature-module 'init-tab)
(require-feature-module 'init-corfu)
(require-feature-module 'init-lsp)

(run-with-idle-timer
 2 nil
 (lambda ()
   (require-feature-module 'init-copilot)))

(require-private-module 'init-private)

(use-package winner
  :straight nil
  :config
  (winner-mode 1))

(global-subword-mode 1)
(setq show-paren-delay 0.02)

(with-eval-after-load 'org-agenda
  (add-hook 'org-agenda-mode-hook #'hl-line-mode))

(setq vc-follow-symlinks t)

(defun my-cleanup-gc ()
  "Reset GC settings after startup."
  (setq gc-cons-threshold 67108864)
  (setq gc-cons-percentage 0.1)
  (garbage-collect))

(run-with-idle-timer 4 nil #'my-cleanup-gc)

(run-with-timer
 0.2 nil
 (lambda ()
   (message "*** Emacs loaded in %s with %d garbage collections."
            (format "%.2f seconds"
                    (float-time (time-subtract after-init-time before-init-time)))
            gcs-done)))

(provide 'init)
;;; init.el ends here
