;; Mac 配置
(when *is-a-mac*
  (use-package org
    :load-path "~/kem/site-lisp/org-lisp"
    :init
    (setq-default org-agenda-files '("~/org/daily"))
    :bind
    ("C-c a" . org-agenda))
  (use-package mpvi
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
                             (org-latex-preview-auto-mode 1))))

;; win 配置
(when *is-a-win*
  (setq-default org-agenda-files '("~/notes/daily")))

;; Linux 配置
(when *is-a-linux*
  (setq-default org-agenda-files '("~/notes/daily"))
  (use-package org
    :load-path "~/.emacs.d/site-lisp/org-mode/lisp"
    :config
    (with-eval-after-load 'org
      (setq org-latex-preview-numbered t
	    org-latex-preview-precompile nil)
      (let ((pos (assoc 'dvisvgm org-latex-preview-process-alist)))
	(plist-put (cdr pos) :image-converter '("dvisvgm --page=1- --optimize --clipjoin --relative --no-fonts --bbox=preview -o %B-%%9p.svg %f"))))
    (setq org-latex-packages-alist
      '(("T1" "fontenc" t)
        ("" "amsmath" t)
        ("" "bm" t) ; Bold math required
        ("" "mathtools" t)
        ("" "siunitx" t)
        ("" "physics2" t)
        ("" "kpfonts" t)))
    :hook
    (org-mode-hook . org-latex-preview-auto-mode)
    ))


;; 通用配置
(use-package org-download
  :ensure t
  :after org)
(use-package denote
  :ensure t
  ;; :vc (:fetcher "github" :repo "protesilaos/denote")
  :bind
  (:prefix-map denote-map
	       :prefix "C-c d"
  ("f" . denote-open-or-create)
  ("d" . denote-journal-extras-new-or-existing-entry))
  :config
  (setq denote-directory org-directory)
  (setq denote-rename-buffer-format "%t-%k")
  (denote-rename-buffer-mode 1)
  (require 'denote-journal-extras)
  (setq denote-journal-extras-directory (concat denote-directory "/daily")))

(use-package tex
  :ensure auctex
  :config
  (defun +rime-predicate-org-latex-mode-p ()
  "If cursor is inside an org-mode's LaTeX fragment, macro or its arguments."
  (and (derived-mode-p  'org-mode)
       (or (texmathp)
           (org-inside-latex-macro-p)))))
;; Use `CDLaTeX' to improve editing experiences
(use-package cdlatex
  :ensure t
  :diminish (org-cdlatex-mode)
  :bind
  (:map org-mode-map
	("C-c s" . cdlatex-environment))
  :config (add-hook 'org-mode-hook #'turn-on-org-cdlatex)
  (setq cdlatex-math-symbol-alist '((97 ("\\alpha")) (65 ("\\forall" "\\aleph")) (98 ("\\beta") ("\\sim"))
 (66 (#1="")) (99 (#1# #1# "\\cos")) (67 (#1# #1# "\\arccos"))
 (100 ("\\delta" "\\partial")) (68 ("\\Delta" "\\nabla"))
 (101 ("\\epsilon" "\\varepsilon" "\\exp"))
 (69 ("\\exists" #1# "\\ln")) (102 ("\\phi" "\\varphi")) (70 (#1#))
 (103 ("\\gamma" #1# "\\lg")) (71 ("\\Gamma" #1# "10^{?}"))
 (104 ("\\eta" "\\hbar")) (72 (#1#)) (105 ("\\in" "\\imath"))
 (73 (#1# "\\Im")) (106 (#1# "\\jmath")) (74 (#1#)) (107 ("\\kappa"))
 (75 (#1#)) (108 ("\\lambda" "\\lim\\limits" "\\log")) (76 ("\\Lambda"))
 (109 ("\\mu")) (77 (#1#)) (110 ("\\nu" #1# "\\ln"))
 (78 ("\\nabla" #1# "\\exp")) (111 ("\\omega"))
 (79 ("\\Omega" "\\mho")) (112 ("\\pi" "\\varpi")) (80 ("\\Pi"))
 (113 ("\\theta" "\\vartheta")) (81 ("\\Theta"))
 (114 ("\\rho" "\\varrho")) (82 (#1# "\\Re"))
 (115 ("\\sigma" "\\varsigma" "\\sum\\limits"))
 (83 ("\\Sigma" #1# "\\arcsin")) (116 ("\\tau" #1# "\\tan"))
 (84 (#1# #1# "\\arctan")) (117 ("\\upsilon")) (85 ("\\Upsilon"))
 (118 ("\\vee")) (86 ("\\Phi")) (119 ("\\xi")) (87 ("\\Xi"))
 (120 ("\\chi")) (88 (#1#)) (121 ("\\psi")) (89 ("\\Psi"))
 (122 ("\\zeta")) (90 (#1#)) (32 (#1#)) (48 ("\\emptyset")) (49 (#1#))
 (50 (#1#)) (51 (#1#)) (52 (#1#)) (53 (#1#)) (54 (#1#)) (55 (#1#))
 (56 ("\\infty")) (57 (#1#)) (33 ("\\neg")) (64 (#1#)) (35 (#1#))
 (36 (#1#)) (37 (#1#)) (94 ("\\uparrow")) (38 ("\\wedge")) (63 (#1#))
 (126 ("\\approx" "\\simeq")) (95 ("\\downarrow")) (43 ("\\cup"))
 (45 ("\\leftrightarrow" "\\longleftrightarrow")) (42 ("\\times"))
 (47 ("\\not")) (124 ("\\mapsto" "\\longmapsto")) (92 ("\\setminus"))
 (34 (#1#)) (61 ("\\Leftrightarrow" "\\Longleftrightarrow"))
 (40 ("\\langle")) (41 ("\\rangle"))
 (91 ("\\Leftarrow" "\\Longleftarrow"))
 (93 ("\\Rightarrow" "\\Longrightarrow")) (123 ("\\subset"))
 (125 ("\\supset")) (60 ("\\leftarrow" "\\longleftarrow" "\\min"))
 (62 ("\\rightarrow" "\\longrightarrow" "\\max")) (96 (#1#))
 (39 ("\\prime")) (46 ("\\cdot")))))

;; To display LaTeX symbols as unicode
(setq org-pretty-entities t)
(setq org-pretty-entities-include-sub-superscripts nil)




;; ui
(use-package org-modern
  :ensure t
  :after (org)
  :init
  (setq org-modern-star '("󰓎"))
  (setq org-modern-hide-stars "󰥺")
  (setq org-modern-list '((?- . "•")))
  (setq org-modern-checkbox '((?X . "󰄲") (?- . "󰥺") (?\s . "󰄮")))
  (setq org-modern-progress '("󰲼" "󰦕" "󱞈" "󰦖" "󰦘"))
  (setq org-modern-table-vertical 2)
  (setq org-modern-block-name nil)
  (setq org-modern-keyword nil)
  (setq org-modern-timestamp nil)
  :config (global-org-modern-mode 1))

(defun my-iconify-org-buffer ()
  (progn
    (push '(":PROPERTIES:" . ?󰑹) prettify-symbols-alist)
    (push '(":ID:      " . ?󰻾) prettify-symbols-alist)
    (push '(":ROAM_ALIASES:" . ?󰑢) prettify-symbols-alist)
    (push '(":END:" . ?) prettify-symbols-alist)
    (push '("#+TITLE:" . ?󰗴) prettify-symbols-alist)
    (push '("#+AUTHOR:" . ?󰸎) prettify-symbols-alist)
    (push '("#+RESULTS:" . ?) prettify-symbols-alist)
    (push '("#+ATTR_ORG:" . ?󰺲) prettify-symbols-alist)
    (push '("#+STARTUP: " . ?󰜉) prettify-symbols-alist))
  (prettify-symbols-mode 1))
(add-hook 'org-mode-hook #'my-iconify-org-buffer)

(setq org-ellipsis " 󰁔")
(setq org-hide-emphasis-markers nil)
(setq org-startup-with-inline-images t)
(setq org-startup-with-latex-preview t)
(use-package org
  :bind
  ("C-c a" . org-agenda)
  :config
  (setq org-todo-keywords
	'((sequence "TODO(t)" "ISSUE(i)" "|" "DONE(d)")
          (sequence "WAITING(w@/!)" "|" "CANCELLED(c@/!)")))

  (setq org-todo-keyword-faces
	'(("TODO" . (:foreground "red" :weight bold))
          ("ISSUE" . (:foreground "orange" :weight bold))
          ("DONE" . (:foreground "green" :weight bold))
          ("WAITING" . (:foreground "blue" :weight bold))
          ("CANCELLED" . (:foreground "gray" :weight bold)))))


(provide 'init-org)
