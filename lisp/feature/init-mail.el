;;; init-mail.el --- Mail support -*- lexical-binding: t; -*-

(require 'auth-source)
(require 'cl-lib)
(require 'subr-x)

(defgroup my/mail nil
  "Personal mail configuration."
  :group 'mail)

(defcustom my/mail-account-name nil
  "Primary mail account name.
Set this in `lisp/init-private.el'."
  :type '(choice (const :tag "Unset" nil) string)
  :group 'my/mail)

(defcustom my/mail-auth-host nil
  "Host key used to find mail credentials in auth-source.
Set this in `lisp/init-private.el'."
  :type '(choice (const :tag "Unset" nil) string)
  :group 'my/mail)

(defcustom my/mail-address nil
  "Explicit From address.
If nil, derive it from auth-source user and `my/mail-auth-host'."
  :type '(choice (const :tag "Use auth-source" nil) string)
  :group 'my/mail)

(defcustom my/mail-full-name nil
  "Full name used when sending mail.
If nil, use the global `user-full-name'."
  :type '(choice (const :tag "Use user-full-name" nil) string)
  :group 'my/mail)

(defcustom my/mail-mbsync-config
  (expand-file-name "etc/mail/mbsyncrc" user-emacs-directory)
  "mbsync config used by mu4e."
  :type 'file
  :group 'my/mail)

(defcustom my/mail-msmtp-config
  (expand-file-name "etc/mail/msmtprc" user-emacs-directory)
  "msmtp config used by message-mode."
  :type 'file
  :group 'my/mail)

(defcustom my/mail-maildir nil
  "Local Maildir root for the primary mail account.
If nil, use var/mail/ACCOUNT under `user-emacs-directory'."
  :type '(choice (const :tag "Derive from account name" nil) directory)
  :group 'my/mail)

(defcustom my/mail-local-archive-folder "/LocalArchive"
  "mu4e folder name for local-only archived message copies."
  :type 'string
  :group 'my/mail)

(defcustom my/mail-drafts-folder "/Drafts"
  "mu4e drafts folder for the primary account."
  :type 'string
  :group 'my/mail)

(defcustom my/mail-sent-folder "/Sent"
  "mu4e sent folder for the primary account."
  :type 'string
  :group 'my/mail)

(defcustom my/mail-trash-folder "/Trash"
  "mu4e trash folder for the primary account."
  :type 'string
  :group 'my/mail)

(defcustom my/mail-refile-folder "/Archive"
  "mu4e refile folder for the primary account."
  :type 'string
  :group 'my/mail)

(defvar my/mail-auto-start-delay 30
  "Idle seconds before starting mu4e in the background.")

(defvar my/mail-auto-start-timer nil
  "Timer used to start mu4e in the background.")

(defun my/mail--nonempty-string-p (value)
  "Return non-nil if VALUE is a non-empty string."
  (and (stringp value) (not (string-empty-p value))))

(defun my/mail-auth-entry ()
  "Return the auth-source entry for `my/mail-auth-host'."
  (when (my/mail--nonempty-string-p my/mail-auth-host)
    (car (auth-source-search :host my/mail-auth-host
                             :require '(:user)
                             :max 1))))

(defun my/mail-account-name ()
  "Return the configured mail account name."
  (or (and (my/mail--nonempty-string-p my/mail-account-name)
           my/mail-account-name)
      (user-error "Set `my/mail-account-name' in lisp/init-private.el")))

(defun my/mail-user ()
  "Return the user name for the primary mail account."
  (or (plist-get (my/mail-auth-entry) :user)
      (when (my/mail--nonempty-string-p my/mail-address)
        (car (split-string my/mail-address "@")))
      (user-error "Set `my/mail-auth-host' or `my/mail-address'")))

(defun my/mail-address ()
  "Return the From address for the primary mail account."
  (or (and (my/mail--nonempty-string-p my/mail-address)
           my/mail-address)
      (let ((user (my/mail-user)))
        (if (string-match-p "@" user)
            user
          (unless (my/mail--nonempty-string-p my/mail-auth-host)
            (user-error "Set `my/mail-auth-host' in lisp/init-private.el"))
          (concat user "@" my/mail-auth-host)))))

(defun my/mail-full-name ()
  "Return the full name used when sending mail."
  (or (and (my/mail--nonempty-string-p my/mail-full-name)
           my/mail-full-name)
      user-full-name))

(defun my/mail-maildir ()
  "Return the local Maildir root for the primary account."
  (or (and (my/mail--nonempty-string-p my/mail-maildir)
           my/mail-maildir)
      (expand-file-name
       (format "var/mail/%s" (my/mail-account-name))
       user-emacs-directory)))

(defun my/mail-local-archive-dir ()
  "Return the local-only Maildir used for archived message copies."
  (expand-file-name
   (string-remove-prefix "/" my/mail-local-archive-folder)
   (my/mail-maildir)))

(defun my/mail-configured-p ()
  "Return non-nil if private mail settings are available."
  (and (my/mail--nonempty-string-p my/mail-account-name)
       (or (my/mail--nonempty-string-p my/mail-address)
           (plist-get (my/mail-auth-entry) :user))
       (file-readable-p my/mail-mbsync-config)
       (file-readable-p my/mail-msmtp-config)))

(defun my/mail-add-mu4e-load-path ()
  "Add common system mu4e install locations to `load-path'."
  (dolist (dir '("/opt/homebrew/share/emacs/site-lisp/mu/mu4e"
                 "/opt/homebrew/share/emacs/site-lisp/mu4e"
                 "/usr/local/share/emacs/site-lisp/mu/mu4e"
                 "/usr/local/share/emacs/site-lisp/mu4e"
                 "/usr/share/emacs/site-lisp/mu4e"))
    (when (file-directory-p dir)
      (add-to-list 'load-path dir))))

(my/mail-add-mu4e-load-path)

(defun my/mail-ensure-local-archive-maildir ()
  "Create the local-only archive Maildir if it is missing."
  (dolist (subdir '("cur" "new" "tmp"))
    (make-directory
     (expand-file-name subdir (my/mail-local-archive-dir)) t)))

(defun my/mail-local-archive-destination (source)
  "Return a unique local archive destination path for SOURCE."
  (my/mail-ensure-local-archive-maildir)
  (let* ((cur-dir (expand-file-name "cur" (my/mail-local-archive-dir)))
         (suffix (if (string-match "\\(:2,[^/]*\\)\\'" source)
                     (match-string 1 source)
                   ""))
         (prefix (format "localarchive.%s.%d.%06x."
                         (format-time-string "%Y%m%dT%H%M%S")
                         (emacs-pid)
                         (random #x1000000))))
    (make-temp-file (expand-file-name prefix cur-dir) nil suffix)))

(defun my/mu4e-copy-message-to-local-archive (&optional msg)
  "Copy MSG, or the message at point, into the local-only archive."
  (interactive)
  (let* ((msg (or msg (mu4e-message-at-point)))
         (source (mu4e-message-field msg :path)))
    (unless (and source (file-readable-p source))
      (user-error "Message file is not readable: %s" source))
    (let ((dest (my/mail-local-archive-destination source)))
      (copy-file source dest t t t)
      (when (fboundp 'mu4e--server-add)
        (mu4e--server-add dest))
      (message "Copied message to %s" my/mail-local-archive-folder))))

(defun my/mail-apply-settings ()
  "Apply private mail settings to mu4e and message-mode."
  (let ((address (my/mail-address))
        (full-name (my/mail-full-name))
        (account-name (my/mail-account-name)))
    (setq user-mail-address address
          user-full-name full-name
          mail-user-agent 'mu4e-user-agent
          read-mail-command 'mu4e
          message-send-mail-function 'message-send-mail-with-sendmail
          sendmail-program (or (executable-find "msmtp") "msmtp")
          message-sendmail-extra-arguments
          (list (concat "--file=" my/mail-msmtp-config)
                "--read-recipients")
          message-kill-buffer-on-exit t
          mu4e-get-mail-command
          (format "mbsync -c %s %s"
                  (shell-quote-argument my/mail-mbsync-config)
                  account-name))
    (when (fboundp 'make-mu4e-context)
      (setq mu4e-contexts
            (list
             (make-mu4e-context
              :name account-name
              :match-func (lambda (_msg) t)
              :vars
              `((user-mail-address . ,address)
                (user-full-name . ,full-name)
                (mu4e-drafts-folder . ,my/mail-drafts-folder)
                (mu4e-sent-folder . ,my/mail-sent-folder)
                (mu4e-trash-folder . ,my/mail-trash-folder)
                (mu4e-refile-folder . ,my/mail-refile-folder))))))))

(defun my/mail-start-mu4e-background ()
  "Start mu4e without displaying its main buffer."
  (when (and (my/mail-configured-p)
             (require 'mu4e nil t))
    (my/mail-apply-settings)
    (mu4e t)))

(defun my/mail-schedule-auto-start ()
  "Schedule background mu4e startup after Emacs is idle."
  (when (timerp my/mail-auto-start-timer)
    (cancel-timer my/mail-auto-start-timer))
  (setq my/mail-auto-start-timer
        (run-with-idle-timer
         my/mail-auto-start-delay nil
         #'my/mail-start-mu4e-background)))

(use-package mu4e
  :straight nil
  :commands (mu4e mu4e-compose-new)
  :bind
  (("C-c m" . mu4e)
   ("C-c M" . mu4e-compose-new))
  :custom
  (mu4e-update-interval 900)
  (mu4e-change-filenames-when-moving t)
  (mu4e-view-show-images t)
  (mu4e-compose-signature-auto-include nil)
  (mu4e-sent-messages-behavior 'sent)
  :config
  (require 'mu4e-server)
  (require 'mu4e-org)
  (define-key mu4e-headers-mode-map
              (kbd "C-c a") #'my/mu4e-copy-message-to-local-archive)
  (define-key mu4e-view-mode-map
              (kbd "C-c a") #'my/mu4e-copy-message-to-local-archive)
  (define-key mu4e-headers-mode-map
              (kbd "C-c c") #'mu4e-org-store-and-capture)
  (define-key mu4e-view-mode-map
              (kbd "C-c c") #'mu4e-org-store-and-capture)
  (add-to-list 'mu4e-headers-actions
               '("local archive copy" . my/mu4e-copy-message-to-local-archive)
               t)
  (add-to-list 'mu4e-view-actions
               '("local archive copy" . my/mu4e-copy-message-to-local-archive)
               t)
  (when (my/mail-configured-p)
    (my/mail-apply-settings)))

(use-package mu4e-org
  :straight nil
  :after (mu4e org)
  :custom
  (mu4e-org-link-query-in-headers-mode nil))

(my/mail-schedule-auto-start)

(provide 'init-mail)
;;; init-mail.el ends here
