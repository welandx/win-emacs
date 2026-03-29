;;; init-org.el --- Org writeup helpers -*- lexical-binding: t; -*-

(defvar org-download-clipboard-command nil)
(declare-function org-download-clipboard "org-download")
(declare-function org-display-inline-images "org")

(let ((extra-paths '("/Users/weland/.emacs.d/bin"
                     "/Library/TeX/texbin"
                     "/Users/weland/.local/bin"
                     "/opt/homebrew/bin")))
  (setenv "PATH"
          (mapconcat #'identity
                     (append extra-paths
                             (list (getenv "PATH")))
                     ":"))
  (dolist (dir (reverse extra-paths))
    (add-to-list 'exec-path dir)))

(setq-default org-agenda-files '("~/notes/daily"))

(use-package org
  :straight nil
  :bind
  (("C-c a" . org-agenda)
   :map org-mode-map
   ("C-c i p" . org-download-clipboard)
   ("C-c i y" . my/org-paste-image-dwim)
   ("C-c i t" . org-toggle-inline-images)
   ("C-c e p" . my/org-insert-pdf-writeup-template)
   ("C-c e h" . my/org-insert-html-writeup-template)
   ("C-c e w" . my/org-insert-writeup-template))
  :hook
  ((org-mode . visual-line-mode)
   (org-mode . my/org-mode-setup)
   (org-babel-after-execute . org-redisplay-inline-images))
  :config
  (require 'ox-html)
  (require 'ox-latex)
  (require 'org-tempo)

  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers nil
        org-pretty-entities t
        org-pretty-entities-include-sub-superscripts nil
        org-image-actual-width '(720)
        org-startup-with-inline-images t
        org-startup-with-latex-preview nil
        org-export-with-smart-quotes t
        org-html-doctype "html5"
        org-html-html5-fancy t
        org-html-validation-link nil
        org-html-head-include-default-style nil
        org-html-head-include-scripts nil
        org-html-postamble nil
        org-html-head-extra my/org-html-style
        org-latex-compiler "xelatex"
        org-latex-src-block-backend 'minted
        org-latex-default-class "org-zh-writeup"
        org-latex-pdf-process '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"
                                "xelatex -shell-escape -interaction nonstopmode -output-directory %o %f")
        org-latex-minted-options '(("breaklines" "true")
                                   ("breakanywhere" "true")
                                   ("breaksymbolleft" "")
                                   ("breaksymbolright" "")
                                   ("autogobble" "true")
                                   ("fontsize" "\\small")
                                   ("encoding" "utf8")
                                   ("tabsize" "2"))
        org-latex-packages-alist '(("" "graphicx" t)
                                   ("" "grffile" t)
                                   ("" "longtable" nil)
                                   ("" "booktabs" nil)
                                   ("" "wrapfig" nil)
                                   ("" "float" nil)
                                   ("" "capt-of" nil)
                                   ("" "fvextra" nil)
                                   ("" "minted" nil)
                                   ("" "amsmath" t)
                                   ("" "amssymb" t)))

  (add-to-list 'org-latex-classes
               '("org-zh-writeup"
                 "\\documentclass[11pt,a4paper]{ctexart}
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
\\linespread{1.2}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

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
    (setq org-download-clipboard-command
          (or (executable-find "pngpaste")
              "pngpaste")))

  (with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "Y") #'org-download-yank)))

(use-package org-modern
  :after org
  :init
  (setq org-modern-table nil
        org-modern-keyword nil
        org-modern-block-name nil)
  :config
  (global-org-modern-mode 1))

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
h1, h2, h3, h4 {
  color: #2d2416;
  line-height: 1.3;
}
h1.title {
  margin-bottom: 0.4rem;
  font-size: 2.2rem;
}
a {
  color: #8a4b08;
}
pre, code {
  font-family: \"SauceCodePro Nerd Font Mono\", \"SF Mono\", \"Menlo\", monospace;
}
pre {
  overflow-x: auto;
  padding: 1rem;
  border-radius: 12px;
  background: #f2ede3;
}
blockquote {
  margin: 1.2rem 0;
  padding: 0.2rem 1rem;
  border-left: 4px solid #c58940;
  background: #fbf7f0;
}
img {
  display: block;
  max-width: 100%;
  margin: 1.2rem auto;
  border-radius: 10px;
}
table {
  border-collapse: collapse;
  width: 100%;
  margin: 1.5rem 0;
}
th, td {
  border: 1px solid #d6ccb8;
  padding: 0.6rem 0.8rem;
}
</style>"
  "Default HTML style used for Org writeups.")

(defconst my/org-writeup-template
  "#+TITLE: Writeup Title
#+AUTHOR: weland
#+DATE: %U
#+LANGUAGE: zh-CN
#+OPTIONS: toc:t num:t ^:nil broken-links:t
#+STARTUP: inlineimages
#+LATEX_CLASS: org-zh-writeup
#+LATEX_COMPILER: xelatex
#+HTML_HEAD_EXTRA: <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">

"
  "Base Org writeup template.")

(defun my/org-buffer-image-dir ()
  "Return a relative asset directory for the current Org buffer."
  (let ((base (if buffer-file-name
                  (file-name-base buffer-file-name)
                "org-buffer")))
    (format "%s-assets" base)))

(defun my/org-mode-setup ()
  "Configure Org mode for image-heavy writeups."
  (setq-local line-spacing 0.12)
  (setq-local org-download-image-dir (my/org-buffer-image-dir))
  (setq-local org-format-latex-options
              (plist-put org-format-latex-options :scale 1.8))
  (org-display-inline-images))

(defun my/org-paste-image-dwim ()
  "Paste an image from the clipboard into the current Org buffer."
  (interactive)
  (require 'org-download)
  (unless (derived-mode-p 'org-mode)
    (user-error "This command only works in org-mode"))
  (unless (executable-find (or org-download-clipboard-command ""))
    (user-error "Clipboard image paste requires pngpaste in PATH"))
  (org-download-clipboard))

(defun my/org--insert-template (extra-lines)
  "Insert a writeup template, optionally with EXTRA-LINES."
  (interactive)
  (when (and buffer-file-name (> (buffer-size) 0))
    (goto-char (point-max))
    (unless (bolp)
      (insert "\n\n")))
  (insert my/org-writeup-template)
  (when extra-lines
    (save-excursion
      (goto-char (point-min))
      (forward-line 7)
      (insert extra-lines)))
  (goto-char (point-min)))

(defun my/org-insert-writeup-template ()
  "Insert a general-purpose writeup template."
  (interactive)
  (my/org--insert-template nil))

(defun my/org-insert-pdf-writeup-template ()
  "Insert a PDF-oriented writeup template."
  (interactive)
  (my/org--insert-template
   "#+LATEX_HEADER: \\usepackage{fvextra}\n#+LATEX_HEADER: \\DefineVerbatimEnvironment{Verbatim}{Verbatim}{breaklines=true,breakanywhere=true}\n"))

(defun my/org-insert-html-writeup-template ()
  "Insert an HTML-oriented writeup template."
  (interactive)
  (my/org--insert-template
   "#+HTML_HEAD_EXTRA: <meta name=\"color-scheme\" content=\"light\">\n"))

(provide 'init-org)
;;; init-org.el ends here
