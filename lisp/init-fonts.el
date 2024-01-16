;; init-fonts.el --- MinEmacs fonts -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2023  Abdelhak Bougouffa

;; Author: Abdelhak Bougouffa (concat "abougouffa" "@" "fedora" "project" "." "org")

;;; Commentary:

;;; Code:

(defcustom minemacs-fonts-plist
  '(:default
     ((:family "SauceCodePro Nerd Font Mono" :height 180)
       (:family "FantasqueSansM Nerd Font Mono" :height 160)
     (:family "SauceCodePro Nerd Font" :height 160)
     (:family "MonoLisa Nasy" :height 150)
     (:family "Agave Nerd Font Mono" :height 150)
     (:family "Iosevka Fixed Curly Slab" :height 150)
     (:family "Iosevka Comfy Fixed" :height 150)
     (:family "Iosevka Fixed Curly" :height 150)
     (:family "Iosevka Comfy Motion Fixed" :height 150)
     (:family "Iosevka" :height 150)
     (:family "Iosevka Comfy" :height 150)
     (:family "Cascadia Code" :height 150)
     (:family "Fira Code" :height 150)
     (:family "Jetbrains Mono" :height 110)
     (:family "Hack" :height 150)
     (:family "Roboto Mono" :height 120)
     (:family "SF Mono" :height 150)
     (:family "Source Code Pro" :height 150)
     (:family "Menlo" :height 150)
     (:family "Monaco" :height 150)
     (:family "Ubuntu Mono" :height 150)
     (:family "DejaVu Sans Mono" :height 150)
     (:family "Consolas" :height 150))
    :fixed-pitch
    ((:inherit default))
    :fixed-pitch-serif
    ((:inherit default))
    :variable-pitch
    ("Agave Nerd Font Mono"
     "Latin Modern Math"
     "Lato"
     "Roboto"
     "Inter"
     "San Francisco"
     "Helvetica Neue"
     "Helvetica"
     "Ubuntu"
     "Liberation Sans"
     "Segoe UI")
    :symbol
    ((:family "Segoe UI Symbol" :scale 0.7 :prepend t)
     (:family "Symbola" :scale 0.7 :prepend t)
     (:family "Symbol" :scale 0.7 :prepend t))
    :emoji
    ((:family "Noto Color Emoji" :scale 0.7 :prepend t)
     (:family "Apple Color Emoji" :scale 0.7 :prepent t)
     (:family "Segoe UI Emoji" :scale 0.7 :prepend t)
     (:family "Quivira" :scale 0.7 :prepend t))
    ;; Arabic script
    :arabic
    ("Amiri Typewriter"
     "KacstOne"
     "Greta Arabic"
     "Scheherazade"
     "Koodak"
     (:family "Amiri" :scale 0.9))
    ;; FIXME Math
    ;; :mathematical
    ;; ((:family "Latin Modern Math" :scale 0.8))
     ;; Chinese script
     :cjk-misc
     ((:family "Tsangerjinkai05" :scale 1.0)
       (:family "LXGW WenKai Screen" :scale 0.9)
       (:family "霞鹜文楷 屏幕阅读版" :scale 0.9)
       (:family "LXGW WenKai GB Screen R" :scale 0.9)
       (:family "TsangerYangMingTi" :scale 1.0))
    :han
     ( (:family "TsangerJinKai05" :scale 1.0)
       (:family "LXGW WenKai Screen" :scale 0.9)
       (:family "霞鹜文楷 屏幕阅读版" :scale 0.9)
       (:family "LXGW WenKai GB Screen R" :scale 0.9)
       (:family "TsangerYangMingTi" :scale 1.0)
     (:family "LXGW Neo Xihei" :scale 1.3)
     (:family "WenQuanYi Micro Hei Mono" :scale 1.3)
     (:family "LXGW WenKai Mono" :scale 1.3)
     (:family "PingFang SC" :scale 1.0)
     (:family "Microsoft Yahei UI" :scale 1.3)
     (:family "Simhei" :scale 1.3)))
  "MinEmacs fonts used by `+setup-fonts'.

The function checks and enables the first available font from these defined in
this plist. This variable can be customized to set font specs for specific Emacs
faces or to enable some language-specific fonts. The plist keywords are either
face names or script names expressed as keywords (with the \":\" prefix).

For example to set `default' face, use `:default', to set the `mode-line' face,
use `:mode-line', and so on. The parameters for each font in these cases (ie.
for face names) are used in the `custom-theme-set-faces' function, so you can
pass any specs (key value pairs) supported by `custom-theme-set-faces' (like
`:weight', `:slant', `:foreground', ...). A list of supported keywords are
available in the variable `+face-attributes'.

You can also setup some language-specific fonts. All scripts supported by Emacs
can be found in `+known-scripts'. The keyword in this plist will be the script
name expressed as a keyword, for example, for `latin' use `:latin', for `arabic'
use `:arabic', for `emoji' use `:emoji', and so on. In this case, the parameters
are used with `set-fontset-font', so you can send any key value pair supported
by `set-fontset-font'. A list of supported keywords in this case is available in
`+font-spec-keywords'.

The value of the extra `:prepend' keyword is passed the last argument to
`set-fontset-font'. The value of the extra `:scale' keyword can be used to set a
scaling factor for the font in Emacs' `face-font-rescale-alist'. See the
`+setup-fonts' implementation for more details."
  :group 'minemacs-ui
  :type 'plist)

(defconst +known-scripts (mapcar #'car script-representative-chars)
  "Supported scripts, like `latin', `arabic', `han', and so on.")

(defconst +face-attributes
  '(:family :foundry :width :height :weight :slant :foreground
    :distant-foreground :background :underline :overline :strike-through :box
    :inverse-video :stipple :font :inherit :extend)
  "Arguments accepted by the `set-face-attribute' function.")

(defconst +font-spec-keywords
  '(:family :foundry :width :weight :slant :adstyle :registry :dpi :size
    :spacing :avgwidth :name :script :lang :otf)
  "Arguments accepted by the `font-spec' function.")

(defun +font--get-valid-args (script-or-face font)
  (if (stringp font)
      `(:family ,font)
    (apply
     #'append
     (mapcar (lambda (a) (list a (plist-get font a)))
             (cl-intersection (+plist-keys font)
                              (if (memq script-or-face +known-scripts)
                                  +font-spec-keywords
                                +face-attributes))))))

(defun +font-installed-p (font-family)
  "Check if FONT-FAMILY is installed on the system."
  (and font-family (member font-family (font-family-list)) t))

(defun +apply-font-or-script (script-or-face)
  "Set font for SCRIPT-OR-FACE from `minemacs-fonts-plist'."
  (catch 'done
    (dolist (font (plist-get minemacs-fonts-plist (intern (format ":%s" script-or-face))))
      (let* ((spec (+font--get-valid-args script-or-face font))
             (scale (and (plistp font) (plist-get font :scale)))
             (prependp (and (plistp font) (plist-get font :family)))
             (family (plist-get spec :family))
             (scriptp (memq script-or-face +known-scripts)))
        (when (or (not family) (+font-installed-p family))
          (if scriptp
              (set-fontset-font t script-or-face (apply #'font-spec spec) nil prependp)
            (custom-theme-set-faces 'user `(,script-or-face ((t ,spec)))))
          (when (and scale family)
            (add-to-list 'face-font-rescale-alist (cons family scale)))
          (+log! "Settinng %s `%s' to `%s'" (if scriptp "script" "face") script-or-face spec)
          (throw 'done spec))))))

;; Inspired by: github.com/seagle0128/.emacs.d/blob/master/custom-example.el
;;;###autoload
(defun +setup-fonts ()
  "Setup fonts."
  (interactive)
  (mapc #'+apply-font-or-script
        (reverse
         (mapcar (lambda (k) (intern (substring (symbol-name k) 1)))
                 (+plist-keys minemacs-fonts-plist))))
  ;; Run hooks
  (run-hooks 'minemacs-after-setup-fonts-hook))

;; FIXME
(+add-hook! (window-setup server-after-make-frame) #'+setup-fonts)
;; (add-hook 'window-setup-hook #'(lambda () (add-hook 'server-after-make-frame-hook #'+setup-fonts)))
(when *is-a-mac*
  (set-fontset-font t 'mathematical "Latin Modern Math-13")
  (set-fontset-font t 'han "LXGW WenKai Screen-17")
  ;; (set-fontset-font t 'han (font-spec :family "LXGW WenKai Screen"
  ;; 				      :scale 1.2));; 说
  )
;; (set-fontset-font t 'latin "Agave Nerd Font Mono")

(provide 'init-fonts)

;;; init-fonts.el ends here
