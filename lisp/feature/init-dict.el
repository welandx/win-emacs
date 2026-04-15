(with-eval-after-load 'ispell
  (let ((dict (expand-file-name "misc/english-words.txt" my-emacs-d)))
    (when (and (null ispell-alternate-dictionary)
               (file-exists-p dict))
      (setq ispell-alternate-dictionary dict)))
  (setq ispell-look-p nil))

(defconst my/emt-lib-path
  (expand-file-name (format "modules/libewt%s" module-file-suffix)
                    user-emacs-directory)
  "Path to the ewt-rs dynamic module consumed by emt.")

(defun my/emt-ready-p ()
  "Return non-nil when the ewt-rs module is ready for emt consumers."
  (and (featurep 'emt)
       (bound-and-true-p emt--lib-loaded)))

(defun my/emt-cjk-char-p (char)
  "Return non-nil when CHAR is a CJK character."
  (and char
       (or (char-category-set char)
           nil)
       (or (aref (char-category-set char) ?c)
           (aref (char-category-set char) ?j)
           (aref (char-category-set char) ?h))))

(defun my/emt-cjk-context-p ()
  "Return non-nil when point is on or adjacent to CJK text."
  (or (my/emt-cjk-char-p (char-after))
      (my/emt-cjk-char-p (char-before))))

(defun my/emt-bounds-of-word ()
  "Return bounds of the current CJK-aware word for Meow and thing-at-point."
  (if (and (my/emt-ready-p)
           (my/emt-cjk-context-p))
      (pcase-let* ((`(,beg . ,end) (emt--get-bounds-at-point 'all))
                   (text (buffer-substring-no-properties beg end))
                   (len (length text))
                   (index (cond
                           ((<= len 0) 0)
                           ((<= (point) beg) 0)
                           ((>= (point) end) (1- len))
                           (t (- (point) beg))))
                   (`(,word-beg . ,word-end)
                    (emt--word-at-point-or-forward-helper
                     text
                     index)))
        (unless (= word-beg word-end)
          (cons (+ beg word-beg) (+ beg word-end))))
    (bounds-of-thing-at-point 'word)))

(defun my/emt-beginning-of-word ()
  "Move point to the beginning of the current CJK-aware word."
  (when-let* ((bounds (my/emt-bounds-of-word)))
    (goto-char (car bounds))))

(defun my/emt-end-of-word ()
  "Move point to the end of the current CJK-aware word."
  (when-let* ((bounds (my/emt-bounds-of-word)))
    (goto-char (cdr bounds))))

(defun my/emt-forward-word (&optional arg)
  "Move by CJK-aware words when emt is enabled, otherwise use `forward-word'."
  (interactive "^p")
  (if (and (my/emt-ready-p)
           (my/emt-cjk-context-p))
      (emt-forward-word (or arg 1))
    (forward-word (or arg 1))))

(use-package emt
  :straight (:host github :repo "roife/emt"
                   :files ("*.el" "module/*" "module"))
  :init
  (setq emt-lib-path my/emt-lib-path)
  :hook
  (after-init . emt-mode)
  :config
  (with-eval-after-load 'meow
    (put 'emt-word 'forward-op #'my/emt-forward-word)
    (put 'emt-word 'beginning-op #'my/emt-beginning-of-word)
    (put 'emt-word 'end-op #'my/emt-end-of-word)
    (meow-thing-register 'emt-word
                         #'my/emt-bounds-of-word
                         #'my/emt-bounds-of-word)
    (setq meow-word-thing 'emt-word)))

(use-package wucuo
  :init
  (setq ispell-program-name "aspell")
  ;; You could add extra option "--camel-case" for camel case code spell checking if Aspell 0.60.8+ is installed
  ;; @see https://github.com/redguardtoo/emacs.d/issues/796
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--camel-case" "--run-together" "--run-together-limit=16"))

  :hook
  (prog-mode . wucuo-start)

  :config
  (setq wucuo-spell-check-buffer-predicate
    (lambda ()
      (not (memq major-mode
             '(dired-mode
                log-edit-mode
                compilation-mode
                help-mode
                profiler-report-mode
                speedbar-mode
                gud-mode
                Info-mode))))))

(provide 'init-dict)
