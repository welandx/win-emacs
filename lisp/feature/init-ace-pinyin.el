;;; init-ace-pinyin.el --- Pinyin-aware avy jumping -*- lexical-binding: t; -*-

(use-package ace-pinyin
  :straight (ace-pinyin :type git :host github :repo "cute-jumper/ace-pinyin")
  :after avy
  :init
  (setq ace-pinyin-use-avy t
        ace-pinyin-enable-punctuation-translation t
        ace-pinyin-treat-word-as-char t)
  :config
  (ace-pinyin-global-mode 1))

(provide 'init-ace-pinyin)
;;; init-ace-pinyin.el ends here
