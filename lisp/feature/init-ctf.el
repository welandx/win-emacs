;;; init-ctf.el --- In-place CTF utilities (Base64, MD5)  -*- lexical-binding: t; -*-

;; ---- Base64 ----
(defun my/ctf-base64-encode (beg end)
  "Base64 encode the region between BEG and END in-place."
  (interactive "r")
  (let ((encoded (base64-encode-string
                  (buffer-substring-no-properties beg end) t)))
    (delete-region beg end)
    (insert encoded)))

(defun my/ctf-base64-encode-nowrap (beg end)
  "Base64 encode region between BEG and END in-place, without line breaks."
  (interactive "r")
  (let ((encoded (base64-encode-string
                  (buffer-substring-no-properties beg end) nil)))
    (delete-region beg end)
    (insert encoded)))

(defun my/ctf-base64-decode (beg end)
  "Base64 decode the region between BEG and END in-place."
  (interactive "r")
  (let ((decoded (condition-case err
                     (base64-decode-string
                      (buffer-substring-no-properties beg end))
                   (error (user-error "Base64 decode failed: %s"
                                      (error-message-string err))))))
    (delete-region beg end)
    (insert decoded)))

;; ---- MD5 ----
(defun my/ctf-md5 (beg end)
  "Replace the region between BEG and END with its MD5 hash (hex)."
  (interactive "r")
  (let ((hash (md5 (buffer-substring-no-properties beg end))))
    (delete-region beg end)
    (insert hash)))

;; ---- Shared menu definition ----
(easy-menu-define my/ctf-menu-def nil
  "CTF utilities."
  '("CTF"
    ("Base64"
     ["Encode" my/ctf-base64-encode
      :active (region-active-p)
      :help "Base64 encode selected region"]
     ["Encode (no wrap)" my/ctf-base64-encode-nowrap
      :active (region-active-p)
      :help "Base64 encode, single line"]
     ["Decode" my/ctf-base64-decode
      :active (region-active-p)
      :help "Base64 decode selected region"])
    ["MD5 Hash" my/ctf-md5
     :active (region-active-p)
     :help "Replace selected region with its MD5 hash"]))

;; ---- Menu bar ----
(defun my/ctf-install-menu-bar ()
  "Install CTF menu into the menu bar."
  (easy-menu-define my/ctf-menu-bar global-map
    "CTF utilities"
    my/ctf-menu-def))

(add-hook 'after-init-hook #'my/ctf-install-menu-bar)

;; ---- Context menu (right-click) ----
(defun my/ctf-context-menu (menu _click)
  "Add CTF items to the context MENU."
  (when (region-active-p)
    (define-key-after menu [my-ctf-sep]
      '(menu-item "--single-line"))
    (define-key-after menu [my-ctf-b64-encode]
      '(menu-item "CTF > Base64 Encode" my/ctf-base64-encode))
    (define-key-after menu [my-ctf-b64-encode-nowrap]
      '(menu-item "CTF > Base64 Encode (no wrap)" my/ctf-base64-encode-nowrap))
    (define-key-after menu [my-ctf-b64-decode]
      '(menu-item "CTF > Base64 Decode" my/ctf-base64-decode))
    (define-key-after menu [my-ctf-md5]
      '(menu-item "CTF > MD5 Hash" my/ctf-md5)))
  menu)

(if (fboundp 'context-menu-mode)
    (context-menu-mode 1))

(if (boundp 'context-menu-functions)
    (add-hook 'context-menu-functions #'my/ctf-context-menu)
  (define-key global-map [mouse-3]
    (lambda (e)
      (interactive "e")
      (let ((menu (make-sparse-keymap "Context")))
        (setq menu (my/ctf-context-menu menu e))
        (popup-menu menu e)))))

(provide 'init-ctf)
;;; init-ctf.el ends here