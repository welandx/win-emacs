;;; init-lib.el --- Shared helpers  -*- lexical-binding: t; -*-

(require 'cl-lib)

(defconst my-emacs-d (file-name-as-directory user-emacs-directory)
  "Directory of emacs.d.")

(defconst my-lisp-dir (expand-file-name "lisp" my-emacs-d)
  "Directory of personal configuration.")

(defconst my-core-dir (expand-file-name "core" my-lisp-dir)
  "Directory of core configuration modules.")

(defconst my-platform-dir (expand-file-name "platform" my-lisp-dir)
  "Directory of platform specific modules.")

(defconst my-feature-dir (expand-file-name "feature" my-lisp-dir)
  "Directory of optional feature modules.")

(setq my-lightweight-mode-p (and (boundp 'startup-now) (eq startup-now t)))

(defun my/module-file (dir module)
  "Return the absolute path for MODULE inside DIR."
  (expand-file-name (format "%s.el" module) dir))

(defun my/load-module (dir module missing-message)
  "Load MODULE from DIR and emit MISSING-MESSAGE when missing."
  (let ((file (my/module-file dir module)))
    (if (file-exists-p file)
        (load file nil 'nomessage)
      (display-warning 'init missing-message :warning))))

(defun require-core-module (module)
  "Load MODULE from the core directory."
  (my/load-module my-core-dir module
                  (format "Missing core module: %s" module)))

(defun require-platform-module (module)
  "Load MODULE from the platform directory."
  (my/load-module my-platform-dir module
                  (format "Missing platform module: %s" module)))

(defun require-feature-module (module &optional maybe-disabled)
  "Load MODULE from the feature directory.
Skip when MAYBE-DISABLED is non-nil and lightweight mode is active."
  (when (or (not maybe-disabled) (not my-lightweight-mode-p))
    (my/load-module my-feature-dir module
                    (format "Missing feature module: %s" module))))

(defun require-private-module (module)
  "Load MODULE from the root lisp directory when it exists."
  (let ((file (my/module-file my-lisp-dir module)))
    (if (file-exists-p file)
        (load file nil 'nomessage)
      (message "Optional private module not found: %s" module))))

(defun my/setup-txt-imenu ()
  (interactive)
  (setq imenu-generic-expression
        '(("default" "^===\\([^=]+\\)===$" 1))))

(defun my-buffer-face-mode-variable ()
  "Set a larger variable-width font for the current buffer."
  (interactive)
  (setq buffer-face-mode-face '(:family "Source Code Pro" :height 200))
  (buffer-face-mode))

(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(defun +plist-keys (plist)
  "Return the keys of PLIST."
  (let (keys)
    (while plist
      (push (car plist) keys)
      (setq plist (cddr plist)))
    keys))

(setq minemacs-msg-level 2)

(defmacro +log! (msg &rest vars)
  "Log MSG and VARS when verbose logging is enabled."
  (when (>= minemacs-msg-level 3)
    `(let ((inhibit-message t))
       (apply #'message (list (concat "[MinEmacs:Log] " ,msg) ,@vars)))))

(defmacro +add-hook! (hooks &rest rest)
  "A convenience macro for adding functions to hooks."
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
        (:depth (setq depth (pop rest)))
        (:local (setq local-p t))
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
  "Convert HOOKS into hook symbols."
  (declare (pure t) (side-effect-free t))
  (let ((hook-list (ensure-list (+unquote hooks))))
    (if (eq (car-safe hooks) 'quote)
        hook-list
      (cl-loop for hook in hook-list
               if (eq (car-safe hook) 'quote)
               collect (cadr hook)
               else collect (intern (format "%s-hook" (symbol-name hook)))))))

(defun +unquote (expr)
  "Return EXPR unquoted."
  (declare (pure t) (side-effect-free t))
  (while (memq (car-safe expr) '(quote function))
    (setq expr (cadr expr)))
  expr)

(defun switch-theme (new-theme)
  "Disable active themes and load NEW-THEME."
  (interactive "STheme: ")
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme new-theme t))

(defvar toggle-one-window-window-configuration nil
  "The window configuration used by `toggle-one-window'.")

(defun toggle-one-window ()
  "Toggle between the current layout and a single window."
  (interactive)
  (if (equal (length (cl-remove-if #'window-dedicated-p (window-list))) 1)
      (if toggle-one-window-window-configuration
          (progn
            (set-window-configuration toggle-one-window-window-configuration)
            (setq toggle-one-window-window-configuration nil))
        (message "No other windows exist."))
    (setq toggle-one-window-window-configuration
          (current-window-configuration))
    (delete-other-windows)))

(defun scratch-buffer ()
  "Switch to or create the *scratch* buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*")))

(defun tab-to-space ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun echo-current-theme ()
  (interactive)
  (message "Current theme: %s" (car custom-enabled-themes)))

(defun buffer-mode (buffer-or-string)
  "Return the major mode associated with BUFFER-OR-STRING."
  (with-current-buffer buffer-or-string
    major-mode))

(defun print-swb ()
  (interactive)
  (message "%d" (string-width (buffer-string))))

(provide 'init-lib)
;;; init-lib.el ends here
