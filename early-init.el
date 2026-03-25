;;; early-init.el --- Startup tweaks  -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)

(unless (bound-and-true-p my-computer-has-smaller-memory-p)
  (setq gc-cons-percentage 0.6)
  (setq gc-cons-threshold most-positive-fixnum))

(setq frame-resize-pixelwise t)
(setq default-frame-alist
      '((menu-bar-lines . 0)
         (tool-bar-lines . 0)
         (scroll-bar-lines . 0)
        (ns-transparent-titlebar . t)
        (alpha-background . 90)
        (width . 120)
        (height . 40)))

(provide 'early-init)
;;; early-init.el ends here
