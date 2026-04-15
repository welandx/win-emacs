;;; init-appine.el --- Native macOS app embedding -*- lexical-binding: t; -*-

(when *is-a-mac*
  (use-package appine
    :straight (appine :type git :host github :repo "chaoswork/appine")
    :commands (appine appine-open-url appine-open-file appine-close appine-kill)
    :bind
    (("C-x a a" . appine)
     ("C-x a u" . appine-open-url)
     ("C-x a o" . appine-open-file))
    :custom
    (appine-use-for-org-links t)))

(provide 'init-appine)
;;; init-appine.el ends here
