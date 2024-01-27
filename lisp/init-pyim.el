(use-package pyim
  :if *is-a-linux*
  :ensure t
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
    "判断是否是evil的normal模式，如果是则返回true.
这个函数用于：`pyim-english-input-switch-functions'."
    (meow-normal-mode-p))
  ;; (setq-default pyim-punctuation-translate-p '(auto yes no))
  (add-hook 'typepad-mode-hook 'pyim-punctuation-toggle)
  (setq-default pyim-english-input-switch-functions
    '(pyim-probe-evil-normal-mode
       pyim-probe-auto-english
       pyim-probe-program-mode)))

(provide 'init-pyim)
