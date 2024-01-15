(defun my/setup-txt-imenu ()
  (interactive)
  (setq imenu-generic-expression
        '(;;("number" "^\\([[:digit:]]+\.[[:digit:]]+\\)" 1) ; 1.1 1.2 ...
          ;;("English" "^\\(No\.[[:digit:]]+\\)" 1) ; No.1 No.2 ...
          ;;("chinese" "^===\\([[:digit:]]+\.[[:ascii:][:nonascii:]]+\\)===" 1)
	  ("default" "^===\\([^=]+\\)===$" 1)
          )))
(defun my-buffer-face-mode-variable ()
  "Set font to a variable width (proportional) fonts in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "Source Code Pro" :height 200))
  (buffer-face-mode))
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))
(cl-defun slot/vc-install (&key (fetcher "github") repo name rev backend)
  "Install a package from a remote if it's not already installed.
This is a thin wrapper around `package-vc-install' in order to
make non-interactive usage more ergonomic.  Takes the following
named arguments:

- FETCHER the remote where to get the package (e.g., \"gitlab\").
  If omitted, this defaults to \"github\".

- REPO should be the name of the repository (e.g.,
  \"slotThe/arXiv-citation\".

- NAME, REV, and BACKEND are as in `package-vc-install' (which
  see)."
  (let* ((url (format "https://www.%s.com/%s" fetcher repo))
         (iname (when name (intern name)))
         (pac-name (or iname (intern (file-name-base repo)))))
    (unless (package-installed-p pac-name)
      (package-vc-install url iname rev backend))))

(defconst my-emacs-d (file-name-as-directory user-emacs-directory)
  "Directory of emacs.d.")

(defconst my-lisp-dir (concat my-emacs-d "lisp")
  "Directory of personal configuration.")

;; Light weight mode, fewer packages are used.
(setq my-lightweight-mode-p (and (boundp 'startup-now) (eq startup-now t)))

(defun require-init (pkg &optional maybe-disabled)
  "Load PKG if MAYBE-DISABLED is nil or it's nil but start up in normal slowly."
  (when (or (not maybe-disabled) (not my-lightweight-mode-p))
    (load (file-truename (format "%s/%s" my-lisp-dir pkg)) t t)))

;; package vc
(require 'cl-lib)
(require 'use-package-core)

(cl-defun slot/vc-install (&key (fetcher "github") repo name rev backend)
  (let* ((url (format "https://www.%s.com/%s" fetcher repo))
         (iname (when name (intern name)))
         (package-name (or iname (intern (file-name-base repo)))))
    (unless (package-installed-p package-name)
      (package-vc-install url iname rev backend))))

(defvar package-vc-use-package-keyword :vc)

(defun package-vc-use-package-set-keyword ()
  (unless (member package-vc-use-package-keyword use-package-keywords)
    (setq use-package-keywords
          (let* ((pos (cl-position :unless use-package-keywords))
                 (head (cl-subseq use-package-keywords 0 (+ 1 pos)))
                 (tail (nthcdr (+ 1 pos) use-package-keywords)))
            (append head (list package-vc-use-package-keyword) tail)))))

(defun use-package-normalize/:vc (name-symbol keyword args)
  (let ((arg (car args)))
    (pcase arg
      ((or `nil `t) (list name-symbol))
      ((pred symbolp) args)
      ((pred listp) (cond
                     ((listp (car arg)) arg)
                     ((string-match "^:" (symbol-name (car arg))) (cons name-symbol arg))
                     ((symbolp (car arg)) args)))
      (_ nil))))

(defun use-package-handler/:vc (name-symbol keyword args rest state)
  (let ((body (use-package-process-keywords name-symbol rest state)))
    ;; This happens at macro expansion time, not when the expanded code is
    ;; compiled or evaluated.
    (if args
        (use-package-concat
         `((unless (package-installed-p ',(pcase (car args)
                                            ((pred symbolp) (car args))
                                            ((pred listp) (car (car args)))))
             (apply #'slot/vc-install ',(cdr args))))
         body)
      body)))

(defun package-vc-use-package-override-:ensure (func name-symbol keyword ensure rest state)
  (let ((ensure (if (plist-member rest :vc)
                    nil
                  ensure)))
    (funcall func name-symbol keyword ensure rest state)))

(defun package-vc-use-package-activate-advice ()
  (advice-add
   'use-package-handler/:ensure
   :around
   #'package-vc-use-package-override-:ensure))

(defun package-vc-use-package-deactivate-advice ()
  (advice-remove
   'use-package-handler/:ensure
   #'package-vc-use-package-override-:ensure))

;; register keyword on require
(package-vc-use-package-set-keyword)

;; font config
(defun +plist-keys (plist)
  "Return the keys of PLIST."
  (let (keys)
    (while plist
      (push (car plist) keys)
      (setq plist (cddr plist)))
    keys))
(setq minemacs-msg-level 2)
(defmacro +log! (msg &rest vars)
  "Log MSG and VARS using `message' when `minemacs-verbose-p' is non-nil."
  (when (>= minemacs-msg-level 3)
    `(let ((inhibit-message t))
      (apply #'message (list (concat "[MinEmacs:Log] " ,msg) ,@vars)))))


;; from doom
(defmacro +add-hook! (hooks &rest rest)
  "A convenience macro for adding N functions to M hooks.

This macro accepts, in order:

  1. The mode(s) or hook(s) to add to. This is either an unquoted mode, an
     unquoted list of modes, a quoted hook variable or a quoted list of hook
     variables.
  2. Optional properties :local, :append, and/or :depth [N], which will make the
     hook buffer-local or append to the list of hooks (respectively),
  3. The function(s) to be added: this can be a quoted function, a quoted list
     thereof, a list of `defun' or `cl-defun' forms, or arbitrary forms (will
     implicitly be wrapped in a lambda).

If the hook function should receive an argument (like in
`enable-theme-functions'), the `args' variable can be expanded in the forms

  (+add-hook! \\='enable-theme-functions
    (message \"Enabled theme: %s\" (car args)))

\(fn HOOKS [:append :local [:depth N]] FUNCTIONS-OR-FORMS...)"
  (declare (indent (lambda (indent-point state)
                     (goto-char indent-point)
                     (when (looking-at-p "\\s-*(")
                       (lisp-indent-defform state indent-point))))
           (debug t))
  (let* ((hook-forms (+resolve-hook-forms hooks))
         (func-forms ())
         (defn-forms ())
         append-p local-p remove-p depth)
    (while (keywordp (car rest))
      (pcase (pop rest)
        (:append (setq append-p t))
        (:depth  (setq depth (pop rest)))
        (:local  (setq local-p t))
        (:remove (setq remove-p t))))
    (while rest
      (let* ((next (pop rest))
             (first (car-safe next)))
        (push (cond ((memq first '(function nil))
                     next)
                    ((eq first 'quote)
                     (let ((quoted (cadr next)))
                       (if (atom quoted)
                           next
                         (when (cdr quoted)
                           (setq rest (cons (list first (cdr quoted)) rest)))
                         (list first (car quoted)))))
                    ((memq first '(defun cl-defun))
                     (push next defn-forms)
                     (list 'function (cadr next)))
                    ((prog1 `(lambda (&rest args) ,@(cons next rest))
                       (setq rest nil))))
              func-forms)))
    `(progn
       ,@defn-forms
       (dolist (hook (nreverse ',hook-forms))
        (dolist (func (list ,@func-forms))
         ,(if remove-p
              `(remove-hook hook func ,local-p)
            `(add-hook hook func ,(or depth append-p) ,local-p)))))))
(defun +resolve-hook-forms (hooks)
  "Convert a list of modes into a list of hook symbols.

If a mode is quoted, it is left as is. If the entire HOOKS list is quoted, the
list is returned as-is."
  (declare (pure t) (side-effect-free t))
  (let ((hook-list (ensure-list (+unquote hooks))))
    (if (eq (car-safe hooks) 'quote)
        hook-list
      (cl-loop for hook in hook-list
               if (eq (car-safe hook) 'quote)
               collect (cadr hook)
               else collect (intern (format "%s-hook" (symbol-name hook)))))))
;; Adapted from `evil-unquote', takes functions into account
(defun +unquote (expr)
  "Return EXPR unquoted."
  (declare (pure t) (side-effect-free t))
  (while (memq (car-safe expr) '(quote function))
    (setq expr (cadr expr)))
  expr)

;; disable current theme before enable another theme
(defun switch-theme (new-theme)
  "禁用当前主题并加载新主题"
  (interactive "SEnter theme name: ")
  (disable-theme (car custom-enabled-themes))
  (load-theme new-theme t))

(defun disable-all-themes ()
  "disable all active themes."
  (dolist (i custom-enabled-themes)
    (disable-theme i)))
(defadvice load-theme (before disable-themes-first activate)
  (disable-all-themes))

(defun my-mouse-click-handler (event)
  "鼠标点击获取信息"
  (interactive "e")
  (let* ((window (posn-window (event-start event)))
         (buffer (window-buffer window))
         (pos (posn-point (event-start event))))
    (message "鼠标点击位置：窗口 %s，缓冲区 %s，位置 %s" window buffer pos)))
;; (global-set-key (kbd "<mouse-1>") 'my-mouse-click-handler)

;; toggle-one-window (from lazycat)
(defvar toggle-one-window-window-configuration nil
  "The window configuration use for `toggle-one-window'.")

(defun toggle-one-window ()
  "Toggle between window layout and one window."
  (interactive)
  ;; (if visual-fill-column-center-text
  ;;   (setq-local visual-fill-column-center-text nil)
  ;;   (setq-local visual-fill-column-center-text t))
  ;; (if visual-fill-column-mode
  ;;   (visual-fill-column-mode -1)
  ;;   (visual-fill-column-mode 1))
  (if (equal (length (cl-remove-if #'window-dedicated-p (window-list))) 1)
    (if toggle-one-window-window-configuration
      (progn
        (set-window-configuration toggle-one-window-window-configuration)
        (setq toggle-one-window-window-configuration nil))
      (message "No other windows exist."))
    (progn
      (setq toggle-one-window-window-configuration (current-window-configuration)))
    (delete-other-windows)))

(defun tab-to-space ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun org-screenshot-on-windows10 ()
  (interactive)
  (setq full-file-name (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
  ;; 如果文件名的长度小于14,放到mainImage文件夹下面
  (if (< (length full-file-name) 14)
      (setq before-file-name-part "main")
    ;;否则,判断文件中是否含有中文(专门给org roam做的优化,不通用,但是也不想改了)
    (if (string-match "\\cc" full-file-name)
        (setq before-file-name-part  (substring (file-name-sans-extension (file-name-nondirectory buffer-file-name)) 0 14))
      (setq before-file-name-part (substring (file-name-sans-extension (file-name-nondirectory buffer-file-name)) 15))))

  (setq imagefile (concat "./" before-file-name-part "Image/"))
  (unless (file-exists-p imagefile)
    (make-directory imagefile))
  (setq filename (concat (make-temp-name (concat imagefile
                                                 "_"
                                                 (format-time-string "%Y%m%d_%H%M%S_")))
                         ".png"))
  (shell-command (concat "powershell -command \"Add-Type -AssemblyName System.Windows.Forms;if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {$image = [System.Windows.Forms.Clipboard]::GetImage();[System.Drawing.Bitmap]$image.Save('"
                         filename "',[System.Drawing.Imaging.ImageFormat]::Png); Write-Output 'clipboard content saved as file'} else {Write-Output 'clipboard does not contain image data'}\""))
  (insert (concat "[[file:" filename "]]"))
  (org-display-inline-images))

(defun echo-current-theme ()
  (interactive)
  (message "Current theme: %s" (car custom-enabled-themes)))

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (with-current-buffer buffer-or-string
     major-mode))

(provide 'init-lib)
