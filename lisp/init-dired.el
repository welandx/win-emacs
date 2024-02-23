(use-package dired
  :defer t
  :hook (dired-mode . dired-hide-details-mode)
  :config
  (when *is-a-win*
   (setq insert-directory-program "gls" dired-use-ls-dired t))
  :custom
  (dired-dwim-target t)
  ;; (dired-listing-switches "-alGhv --group-directories-first")
  (dired-recursive-copies 'always)
  (dired-kill-when-opening-new-dired-buffer t))

(provide 'init-dired)
