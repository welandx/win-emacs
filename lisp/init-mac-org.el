(use-package org
  :elpaca nil
  :load-path "~/kem/site-lisp/org-lisp"
  :init
  (setq-default org-agenda-files '("~/org/daily"))
  :bind
  ("C-c a" . org-agenda))
(use-package mpvi
  :elpaca nil
  :ensure t
  :config
  (setq mpvi-danmaku2ass "~/Documents/GitHub/danmaku2ass/danmaku2ass.py")
  :bind
  ("C-c s" . mpvi-seek)
  ("C-c i" . mpvi-insert))
(with-eval-after-load 'org
  (defun my/org-latex-preview-center (ov)
    (save-excursion
      (goto-char (overlay-start ov))
      (when-let* ((elem (org-element-context))
                   ((or (eq (org-element-type elem) 'latex-environment)
                      (string-match-p
                        "^\\\\\\[" (org-element-property :value elem))))
                   (img (overlay-get ov 'display))
                   (width (car-safe (image-display-size img)))
                   (offset (floor (- (window-max-chars-per-line) width) 2))
                   ((> offset 0)))
        (overlay-put ov 'before-string
          (propertize
            (make-string offset ?\ )
            'face (org-latex-preview--face-around
                    (overlay-start ov) (overlay-end ov)))))))
  (add-hook 'org-latex-preview-update-overlay-functions
    #'my/org-latex-preview-center)
  ;; src: https://stackoverflow.com/questions/17478260/completely-hide-the-properties-drawer-in-org-mode
  (setq org-latex-preview-default-process 'dvisvgm)
  (setq org-latex-packages-alist
    '(("T1" "fontenc" t)
       ("" "amsmath" t)
       ("" "bm" t) ; Bold math required
       ("" "mathtools" t)
       ("" "siunitx" t)
       ("" "physics2" t)
       ("" "kpfonts" t)))

  (setq org-latex-preview-preamble
    "\\documentclass{article}
[DEFAULT-PACKAGES]
[PACKAGES]
\\usepackage{xcolor}
\\usephysicsmodule{ab,ab.braket,diagmat,xmat}%
")
  (plist-put org-latex-preview-options :scale 2.20)
  (plist-put org-latex-preview-options :zoom 1.15)
  (setq org-latex-preview-numbered t)
  (setq org-latex-preview-width 0.6)
  ;; (let ((pos (assoc 'dvisvgm org-latex-preview-process-alist)))
  ;;      (plist-put (cdr pos) :image-converter '("dvisvgm --page=1- --optimize --clipjoin --relative --no-fonts --bbox=preview -o %B-%%9p.svg %f")))
  (defun elemacs/org-cycle-hide-drawers (state)
    "Re-hide all drawers after a visibility state change."
    (when (and (derived-mode-p 'org-mode)
            (not (memq state '(overview folded contents))))
      (save-excursion
        (let* ((globalp (memq state '(contents all)))
                (beg (if globalp
                       (point-min)
                       (point)))
                (end (if globalp
                       (point-max)
                       (if (eq state 'children)
                         (save-excursion
                           (outline-next-heading)
                           (point))
                         (org-end-of-subtree t)))))
          (goto-char beg)
          (while (re-search-forward org-drawer-regexp end t)
            (save-excursion
              (beginning-of-line 1)
              (when (looking-at org-drawer-regexp)
                (let* ((start (1- (match-beginning 0)))
                        (limit
                          (save-excursion
                            (outline-next-heading)
                            (point)))
                        (msg (format
                               (concat
                                 "org-cycle-hide-drawers:  "
                                 "`:END:`"
                                 " line missing at position %s")
                               (1+ start))))
                  (if (re-search-forward "^[ \t]*:END:" limit t)
                    (outline-flag-region start (line-end-position) t)
                    (user-error msg))))))))))

;;;###autoload
  (defun eli/org-expand-all ()
    (interactive)
    (org-fold-show-subtree)
    (org-unlogged-message "ALL")
    (setq org-cycle-subtree-status 'all))

  (add-hook 'org-cycle-hook #'org-cycle-hide-drawers)
  (advice-add 'org-cycle-hide-drawers :override #'elemacs/org-cycle-hide-drawers)
  (advice-add 'org-insert-heading-respect-content :after #'eli/org-expand-all)
  (define-key org-mode-map [C-tab] #'eli/org-expand-all)
  )
(add-hook 'org-mode-hook #'(lambda ()
                             (org-latex-preview-auto-mode 1)))

(setq org-link-search-must-match-exact-headline nil)
(setq org-open-link-functions nil)
(setq org-modern-table nil)
(provide 'init-mac-org)
