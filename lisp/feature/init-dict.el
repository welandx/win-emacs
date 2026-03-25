(with-eval-after-load 'ispell
  (let ((dict (expand-file-name "misc/english-words.txt" my-emacs-d)))
    (when (and (null ispell-alternate-dictionary)
               (file-exists-p dict))
      (setq ispell-alternate-dictionary dict)))
  (setq ispell-look-p nil))


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
