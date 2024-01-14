(use-package pyim
  :if *is-a-linux*
  :ensure t
  :config
  (setq default-input-method "pyim")
  (pyim-scheme-add
    '(huma
      :document
      "虎码方案"
      :class xingma
      :code-prefix "huma/"
      :first-chars "abcdefghijklmnopqrstuvwxyz"
      :rest-chars "abcdefghijklmnopqrstuvwxyz"
      :code-prefix-history ("_")
      :code-split-length 4
      :code-maximum-length 4))
  ;;----'默认码表'
  (pyim-default-scheme 'huma)
  (defun pyim-probe-evil-normal-mode ()
    "判断是否是evil的normal模式，如果是则返回true.
这个函数用于：`pyim-english-input-switch-functions'."
    (meow-normal-mode-p))

  (setq-default pyim-english-input-switch-functions
    '(pyim-probe-evil-normal-mode)))

(provide 'init-pyim)
