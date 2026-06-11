;;; init-org.el --- Org configuration -*- lexical-binding: t; -*-

;; Sections:
;;   Shared helpers  — HTML CSS, LaTeX writeup class, TAB dwim
;;   Core org        — directories, agenda, capture, todo, log, export
;;   Image paste     — org-download
;;   Visual          — org-modern
;;   LaTeX preview   — ctex + lualatex + dvisvgm(pdf) + mutool
;;   CDLaTeX         — math input
;;   Denote          — file naming / notes
;;   AucTeX          — tex editing
;;   Notifications   — alert osx-notifier

(require 'init-org-ai)  ; provides my/org-directory, my/org-ai-*, shared todo keywords

(declare-function org-download-clipboard "org-download")
(declare-function org-display-inline-images "org")
(declare-function cdlatex-tab "cdlatex")
(declare-function yas-active-snippets "yasnippet")
(declare-function yas-expand-from-trigger-key "yasnippet")
(declare-function yas-next-field-or-maybe-expand "yasnippet")


;;;; PATH for TeX binaries

(let ((extra-paths '("/Users/weland/.emacs.d/bin"
                     "/Library/TeX/texbin"
                     "/Users/weland/.local/bin"
                     "/opt/homebrew/bin")))
  (setenv "PATH"
          (mapconcat #'identity
                     (append extra-paths (list (getenv "PATH")))
                     ":"))
  (dolist (dir (reverse extra-paths))
    (add-to-list 'exec-path dir)))


;;;; Shared helpers

(defconst my/org-archive-directory
  (expand-file-name "archive" my/org-directory)
  "Directory used for archived Org tasks.")

(defconst my/org-html-style
  "<style>
body {
  margin: 0 auto;
  max-width: 980px;
  padding: 2.5rem 1.25rem 4rem;
  color: #1f2328;
  background: #f7f4ec;
  font-family: \"LXGW WenKai Screen\", \"PingFang SC\", \"Hiragino Sans GB\", \"Microsoft YaHei UI\", sans-serif;
  line-height: 1.75;
}
#content {
  background: rgba(255,255,255,0.82);
  padding: 2.2rem 2rem 3rem;
  border-radius: 18px;
  box-shadow: 0 18px 60px rgba(62, 46, 24, 0.08);
}
h1, h2, h3, h4 { color: #2d2416; line-height: 1.3; }
h1.title { margin-bottom: 0.4rem; font-size: 2.2rem; }
a { color: #8a4b08; }
pre, code { font-family: \"SauceCodePro Nerd Font Mono\", \"SF Mono\", \"Menlo\", monospace; }
pre { overflow-x: auto; padding: 1rem; border-radius: 12px; background: #f2ede3; }
blockquote { margin: 1.2rem 0; padding: 0.2rem 1rem; border-left: 4px solid #c58940; background: #fbf7f0; }
img { display: block; max-width: 100%; margin: 1.2rem auto; border-radius: 10px; }
table { border-collapse: collapse; width: 100%; margin: 1.5rem 0; }
th, td { border: 1px solid #d6ccb8; padding: 0.6rem 0.8rem; }
</style>"
  "Default HTML style used for Org writeups.")

(defconst my/org-zh-writeup-class
  '("org-zh-writeup"
    "\\documentclass[11pt,a4paper,fontset=none]{ctexart}
\\setCJKmainfont{Songti SC}
\\setCJKsansfont{PingFang SC}
\\setCJKmonofont{Songti SC}
\\usepackage[margin=1in]{geometry}
\\usepackage{graphicx}
\\usepackage{grffile}
\\usepackage{longtable}
\\usepackage{booktabs}
\\usepackage{float}
\\usepackage{wrapfig}
\\usepackage{capt-of}
\\usepackage{xcolor}
\\usepackage{hyperref}
\\hypersetup{colorlinks=true,linkcolor=black,urlcolor=blue,citecolor=black}
\\setlength{\\parindent}{2em}
\\linespread{1.2}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\usepackage{mathtools}
\\usepackage{amsthm}
\\usepackage{bm}"
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")
    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
    ("\\paragraph{%s}" . "\\paragraph*{%s}")
    ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
  "LaTeX class definition for Chinese writeups.")

(defun my/org-point-in-latex-p ()
  "Return non-nil when point is inside an Org LaTeX construct."
  (memq (org-element-type (org-element-context))
        '(latex-fragment latex-environment entity)))

(defun my/org-math-tab-dwim ()
  "Use snippets and CDLaTeX in math, otherwise keep normal Org TAB behavior."
  (interactive)
  (cond
   ((org-at-table-p)
    (org-cycle))
   ((and (bound-and-true-p yas-minor-mode)
         (yas-active-snippets))
    (yas-next-field-or-maybe-expand))
   ((and (bound-and-true-p org-cdlatex-mode)
         (my/org-point-in-latex-p))
    (or (and (bound-and-true-p yas-minor-mode)
             (yas-expand-from-trigger-key))
        (cdlatex-tab)))
   (t
    (org-cycle))))

(defun my/org-buffer-image-dir ()
  "Return the image directory for the current Org buffer."
  (if buffer-file-name
      (expand-file-name "assets" (file-name-directory buffer-file-name))
    (expand-file-name "assets" default-directory)))

(defun my/org-mode-setup ()
  "Configure Org mode for image-heavy writeups."
  (setq-local line-spacing 0.12)
  (setq-local org-download-image-dir (my/org-buffer-image-dir))
  (unless (file-directory-p org-download-image-dir)
    (make-directory org-download-image-dir t))
  (org-display-inline-images))

(defun my/org-paste-image-dwim ()
  "Paste an image from the clipboard into the current Org buffer."
  (interactive)
  (require 'org-download)
  (unless (derived-mode-p 'org-mode)
    (user-error "This command only works in org-mode"))
  (unless (executable-find (or (bound-and-true-p org-download-clipboard-command) ""))
    (user-error "Clipboard image paste requires pngpaste in PATH"))
  (org-download-clipboard))


;;;; Core org

(use-package org
  :straight nil
  :bind
  (("C-c a" . org-agenda)
   :map org-mode-map
   ("<tab>" . my/org-math-tab-dwim)
   ("C-c i p" . org-download-clipboard)
   ("C-c i y" . my/org-paste-image-dwim)
   ("C-c i t" . org-toggle-inline-images)
   ("C-c x l" . org-latex-preview))
  :hook
  ((org-mode . visual-line-mode)
   (org-mode . my/org-mode-setup)
   (org-babel-after-execute . org-redisplay-inline-images))
  :config
  (require 'ox-html)
  (require 'ox-latex)
  (require 'org-tempo)

  (setq org-directory my/org-directory
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-todo-keywords my/org-ai-todo-keywords
        org-todo-keyword-faces '(("NEXT" . "DeepSkyBlue")
                                 ("WAIT" . "goldenrod")
                                 ("CANCELLED" . "gray50"))
        org-log-done 'time
        org-log-into-drawer t
        org-log-reschedule 'time
        org-log-redeadline 'time
        org-enforce-todo-dependencies t
        org-enforce-todo-checkbox-dependencies t
        org-tag-alist '(("ai" . ?a)
                        ("deep" . ?d)
                        ("quick" . ?q)
                        ("meeting" . ?m)
                        ("errand" . ?e))
        org-ellipsis " ▾"
        org-hide-emphasis-markers nil
        org-pretty-entities t
        org-pretty-entities-include-sub-superscripts nil
        org-image-actual-width '(720)
        org-startup-with-inline-images t
        org-startup-with-latex-preview nil

        ;; Agenda
        org-agenda-window-setup 'current-window
        org-agenda-span 'day
        org-agenda-start-with-log-mode t
        org-agenda-start-with-follow-mode nil
        org-agenda-skip-deadline-prewarning-if-scheduled t
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-skip-timestamp-if-done t
        org-agenda-block-separator ?─
        org-agenda-sorting-strategy '((agenda habit-down time-up priority-down category-keep)
                                      (todo priority-down category-keep)
                                      (tags priority-down category-keep)
                                      (search category-keep))
        org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-agenda-overriding-header "Today")))
            (todo "NEXT" ((org-agenda-overriding-header "Next Actions")))
            (todo "WAIT" ((org-agenda-overriding-header "Waiting")))
            (todo "TODO" ((org-agenda-overriding-header "Inbox / Backlog")))))
          ("A" "AI Task Board"
           ((tags-todo "+ai/TODO"
                       ((org-agenda-overriding-header "AI Inbox / Needs Triage")
                        (org-agenda-skip-function
                         '(org-agenda-skip-entry-if 'scheduled 'deadline))))
            (tags-todo "+ai/NEXT"
                       ((org-agenda-overriding-header "AI Next Actions")))
            (agenda "" ((org-agenda-span 7)
                        (org-agenda-overriding-header "AI Schedule")
                        (org-agenda-tag-filter-preset '("+ai"))))
            (tags-todo "+ai/WAIT"
                       ((org-agenda-overriding-header "AI Waiting")))))
          ("n" "Next Actions" todo "NEXT")
          ("w" "Waiting" todo "WAIT")
          ("r" "Weekly Review"
           ((agenda "" ((org-agenda-span 7)
                        (org-agenda-start-on-weekday 1)
                        (org-agenda-overriding-header "This Week")))
            (todo "TODO|NEXT|WAIT"
                  ((org-agenda-overriding-header "Open Tasks"))))))

        ;; Capture / refile / archive
        org-capture-templates
        `(("a" "AI task" entry
           (file+headline ,my/org-ai-inbox-file ,my/org-ai-inbox-heading)
           "** TODO %^{Title} :ai:\n:PROPERTIES:\n:CAPTURED_BY: manual\n:CREATED_AT: %U\n:END:\n%?"
           :empty-lines 1))
        org-refile-targets '((org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-archive-location
        (concat (file-name-as-directory my/org-archive-directory) "%s_archive::")

        ;; Export (HTML)
        org-export-with-smart-quotes t
        org-html-doctype "html5"
        org-html-html5-fancy t
        org-html-validation-link nil
        org-html-head-include-default-style nil
        org-html-head-include-scripts nil
        org-html-postamble nil
        org-html-head-extra my/org-html-style

        ;; Export (LaTeX)
        org-latex-compiler "xelatex"
        org-latex-src-block-backend 'minted
        org-latex-default-class "org-zh-writeup"
        org-latex-pdf-process '("mkdir -p .ltxout"
                                "xelatex -shell-escape -interaction nonstopmode -output-directory .ltxout %f"
                                "xelatex -shell-escape -interaction nonstopmode -output-directory .ltxout %f"
                                "mv .ltxout/%b.pdf %o")
        org-latex-default-packages-alist nil
        org-latex-packages-alist nil
        org-latex-minted-options '(("breaklines" "true")
                                   ("breakanywhere" "true")
                                   ("breaksymbolleft" "")
                                   ("breaksymbolright" "")
                                   ("autogobble" "true")
                                   ("fontsize" "\\small")
                                   ("encoding" "utf8")
                                   ("tabsize" "2")))

  (make-directory org-directory t)
  (make-directory my/org-archive-directory t)
  (my/org-ai-refresh-agenda-files)
  (advice-add 'org-agenda :before (lambda (&rest _) (my/org-ai-refresh-agenda-files)))
  (add-to-list 'org-latex-classes my/org-zh-writeup-class))


;;;; Image paste

(use-package org-download
  :after org
  :config
  (setq org-download-method 'directory
        org-download-heading-lvl nil
        org-download-screenshot-basename "screenshot.png"
        org-download-image-attr-list '("#+ATTR_ORG: :width 720")
        org-download-display-inline-images t)
  (when *is-a-mac*
    (setq org-download-screenshot-method "screencapture -i %s")
    (defvar org-download-clipboard-command
      (or (executable-find "pngpaste") "pngpaste")))
  (with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "Y") #'org-download-yank)))


;;;; Visual

(use-package valign
  :hook (org-mode . valign-mode))

(use-package org-modern
  :after org
  :init
  (setq org-modern-table nil
        org-modern-keyword nil
        org-modern-block-name nil
        org-modern-fold-stars '(("▶" . "▼")
                                ("▷" . "▽")
                                ("▸" . "▾")))
  :config
  (global-org-modern-mode 1))


;;;; LaTeX preview
;; macOS 15+ notes (see memory/macos_ctex_latex_preview.md):
;;   1. ctex auto-fontset fails (STKaiti moved to AssetsV2) → fontset=none + Songti SC
;;   2. dvilualatex + luatexja fails → map lualatex to lualatex (PDF mode)
;;   3. dvisvgm needs mutool (mupdf-tools) — Ghostscript >= 10.01 unsupported
;;   4. preview.sty dvips option breaks tightpage in PDF mode → remove dvips

(use-package org-latex-preview
  :straight nil
  :after org
  :config
  (plist-put org-latex-preview-appearance-options :page-width 0.8)
  (setq org-latex-preview-process-precompile nil
        org-latex-preview-mode-display-live t
        org-latex-preview-mode-update-delay 0.25)
  (setf (alist-get "lualatex" org-latex-preview-compiler-command-map nil nil #'equal)
        "lualatex")
  (setq org-latex-preview--include-preview-string
        "\n\\usepackage[active,tightpage,auctex]{preview}\n")
  (setq org-latex-preview-preamble
        (string-replace "\\documentclass{article}"
                        "\\documentclass[fontset=none]{ctexart}
\\setCJKmainfont{Songti SC}
\\setCJKsansfont{PingFang SC}
\\setCJKmonofont{Songti SC}"
                        org-latex-preview-preamble))
  (setf (alist-get 'dvisvgm org-latex-preview-process-alist)
        '(:programs ("lualatex" "dvisvgm")
          :description "pdf > svg (lualatex)"
          :message "needs: lualatex, dvisvgm, and mutool (brew install mupdf-tools)."
          :image-input-type "pdf"
          :image-output-type "svg"
          :latex-compiler ("lualatex -interaction nonstopmode -output-directory %o %f")
          :latex-precompiler ("lualatex -output-directory %o -ini -jobname=%b \"&lualatex\" mylatexformat.ltx %f")
          :image-converter ("dvisvgm --pdf --page=1- --optimize --clipjoin --relative --no-fonts --bbox=preview -o %B-%%9p.svg %f")))
  (add-hook 'org-mode-hook 'org-latex-preview-mode))

(when *is-a-mac*
  (setenv "LIBGS" "/opt/homebrew/lib/libgs.dylib"))


;;;; CDLaTeX

(use-package cdlatex
  :after org
  :hook (org-mode . turn-on-org-cdlatex)
  :bind (:map org-mode-map ("C-c {" . cdlatex-environment))
  :config
  (setq cdlatex-use-dollar-to-ensure-math nil))


;;;; Denote

(use-package denote
  :bind (:prefix-map my/denote-map
                     :prefix "C-c d"
                     ("d" . denote)
                     ("f" . denote-open-or-create)
                     ("r" . denote-rename-file)
                     ("l" . denote-link-or-create))
  :hook (org-mode . denote-rename-buffer-mode)
  :config
  (setq denote-directory my/org-directory
        denote-known-keywords '("math" "algebra" "analysis" "geometry" "logic" "topology")
        denote-infer-keywords t
        denote-sort-keywords t
        denote-rename-buffer-format "[D] %t"))


;;;; AucTeX

(use-package tex
  :straight auctex
  :defer t)


;;;; Notifications (alert osx-notifier on macOS, message elsewhere)

(use-package alert
  :commands (alert)
  :config
  (setq alert-default-style (if *is-a-mac* 'osx-notifier 'message)))

(provide 'init-org)
;;; init-org.el ends here
