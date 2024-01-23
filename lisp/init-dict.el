(defun text-mode-hook-setup ()
  (interactive)
  ;; make `company-backends' local is critcal
  ;; or else, you will have completion in every major mode, that's very annoying!
  (make-local-variable 'company-backends)

  ;; company-ispell is the plugin to complete words
  (add-to-list 'company-backends 'company-ispell)

  ;; OPTIONAL, if `company-ispell-dictionary' is nil, `ispell-complete-word-dict' is used
  ;;  but I prefer hard code the dictionary path. That's more portable.
  (setq company-ispell-dictionary (file-truename "~/.emacs.d/misc/english-words.txt")))

(add-hook 'text-mode-hook 'text-mode-hook-setup)

(defun my-company-ispell-available-hack (orig-func &rest args)
    ;; in case evil is disabled
    (cond
     ((and (derived-mode-p 'prog-mode)
           (not (company-in-string-or-comment)) ; respect advice in `company-in-string-or-comment'
               ;; I renamed the api in new version of evil-nerd-commenter
               ) ; auto-complete in comment only
      ;; only use company-ispell in comment when coding
      nil)
     (t
      (apply orig-func args))))
(with-eval-after-load 'company-ispell
  (advice-add 'company-ispell-available :around #'my-company-ispell-available-hack))

(with-eval-after-load 'ispell
  ;; `ispell-alternate-dictionary' is a plain text dictionary if it exists
  (let* ((dict (concat (expand-file-name my-emacs-d) "misc/english-words.txt")))
    (when (and (null ispell-alternate-dictionary)
               (file-exists-p dict))
      ;; @see https://github.com/redguardtoo/emacs.d/issues/977
      ;; fallback to built in dictionary
      (setq ispell-alternate-dictionary dict))))

;; {{ setup company-ispell
(defun toggle-company-ispell ()
  "Toggle company ispell backend."
  (interactive)
  (cond
   ((memq 'company-ispell company-backends)
    (setq company-backends (delete 'company-ispell company-backends))
    (message "company-ispell disabled"))
   (t
    (push 'company-ispell company-backends)
    (message "company-ispell enabled!"))))

(with-eval-after-load 'ispell
  ;; "look" is not reliable, use "grep" instead.
  ;; For example, Linux CLI "/usr/bin/look -df Monday /usr/share/dict/words"
  ;; returns nothing on my Debian Linux testing version.
  (setq ispell-look-p nil))

(defun my-company-ispell-setup ()
  ;; @see https://github.com/company-mode/company-mode/issues/50
  (when (boundp 'company-backends)
    (make-local-variable 'company-backends)
    (push 'company-ispell company-backends)

    (cond
     ;; @see https://github.com/redguardtoo/emacs.d/issues/473
     ;; Windows users never load ispell module
     ((and (boundp 'ispell-alternate-dictionary)
           ispell-alternate-dictionary)
      (setq company-ispell-dictionary ispell-alternate-dictionary))

     (t
      (setq company-ispell-dictionary
            (concat (expand-file-name my-emacs-d) "misc/english-words.txt"))))))

;; message-mode use company-bbdb.
;; So we should NOT turn on company-ispell
(add-hook 'org-mode-hook 'my-company-ispell-setup)

(use-package company-english-helper
  :defer 2
  :vc (:fetcher "github" :repo "manateelazycat/company-english-helper"))


(use-package wucuo
  :ensure t

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
