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
(provide 'init-lib)
