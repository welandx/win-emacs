(when *is-a-mac*
  (use-package org
    :load-path "~/.emacs.d/site-lisp/org")
  (use-package mpvi
  :ensure t
  :config
  (setq mpvi-danmaku2ass "~/Documents/GitHub/danmaku2ass/danmaku2ass.py")
  :bind
  ("C-c s" . mpvi-seek)
  ("C-c i" . mpvi-insert)))
(use-package org-download
  :ensure t
  :after org)
(use-package denote
  :ensure t
  :bind
  ("C-c d" . denote)
  :config
  (setq denote-directory org-directory))

(provide 'init-org)
