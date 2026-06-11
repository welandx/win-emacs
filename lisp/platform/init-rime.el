(use-package rime
  :if *is-a-mac*
  :custom
  (default-input-method "rime")
  (rime-show-candidate 'minibuffer)
  (rime-disable-predicates
   '(meow-normal-mode-p
     meow-motion-mode-p
     rime-predicate-space-after-cc-p
     rime-predicate-after-alphabet-char-p))
  :bind
  (:map rime-mode-map
    ("M-j" . rime-inline-ascii)
    ("C-;" . rime-force-enable))
  :config
  (setq rime-librime-root "/opt/homebrew")
  (setq rime-share-data-dir
        (expand-file-name "rime" user-emacs-directory)))

(provide 'init-rime)
;;; init-rime.el ends here
