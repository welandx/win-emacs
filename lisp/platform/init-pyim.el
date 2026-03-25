(use-package pyim
  :if *is-a-linux*
  :config
  (setq default-input-method "pyim")
  (setq pyim-page-posframe-min-width 15) ;; 不需要那么长的候选框
  (pyim-scheme-add
    '(hmdz
       :document
       "虎码单字"
       :class xingma
       :code-prefix "hmdz/"
       :first-chars "abcdefghijklmnopqrstuvwxyz"
       :rest-chars "abcdefghijklmnopqrstuvwxyz"
       :code-prefix-history ("_")
       :code-split-length 4
       :code-maximum-length 4))
  (pyim-default-scheme 'hmdz)
  (defun pyim-probe-evil-normal-mode ()
    "Use English input while Evil is in normal state."
    (and (bound-and-true-p evil-local-mode)
         (fboundp 'evil-normal-state-p)
         (evil-normal-state-p)))
  ;; (setq-default pyim-punctuation-translate-p '(auto yes no))
  (add-hook 'typepad-mode-hook 'pyim-punctuation-toggle)
  (setq-default pyim-english-input-switch-functions
    '(pyim-probe-evil-normal-mode
       pyim-probe-auto-english
       pyim-probe-program-mode)))

(provide 'init-pyim)
