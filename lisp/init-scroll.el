(if *is-a-mac*
 (use-package ultra-scroll-mac
  :if (eq window-system 'mac)
  :vc (:fetcher "github" :repo "jdtsmith/ultra-scroll-mac")
  :init
  (setq scroll-conservatively 101)
  :config
  (ultra-scroll-mac-mode 1))

(let* ((minver "29"))
  (unless (version< emacs-version minver)
    (pixel-scroll-precision-mode 1)))
(setq pixel-scroll-precision-interpolate-page t) ;; smooth scroll M-v C-v
(defun +pixel-scroll-interpolate-down (&optional lines)
  (interactive)
  (if lines
      (pixel-scroll-precision-interpolate (* -1 lines (pixel-line-height)))
    (pixel-scroll-interpolate-down)))

(defun +pixel-scroll-interpolate-up (&optional lines)
  (interactive)
  (if lines
      (pixel-scroll-precision-interpolate (* lines (pixel-line-height))))
  (pixel-scroll-interpolate-up))

(defalias 'scroll-up-command '+pixel-scroll-interpolate-down)
(defalias 'scroll-down-command '+pixel-scroll-interpolate-up))
(provide 'init-scroll)
