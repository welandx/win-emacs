;; 配合 meow, keypad 与 respect-mode 有冲突
(with-eval-after-load 'sis
    (add-hook 'meow-insert-exit-hook #'sis-set-english)
    (add-to-list 'sis-context-hooks 'meow-insert-enter-hook))

(use-package sis
  :ensure t
  :init
  ;; `C-s/r' 默认优先使用英文 必须在 sis-global-respect-mode 前配置
  (setq sis-respect-go-english-triggers
        (list 'isearch-forward 'isearch-backward) ; isearch-forward 命令时默认进入en
        sis-respect-restore-triggers
        (list 'isearch-exit 'isearch-abort)) ; isearch-forward 恢复, isearch-exit `<Enter>', isearch-abor `C-g'
:config
(when *is-a-win*
  (sis-ism-lazyman-config nil t 'w32))
(when *is-a-mac*
  (setq sis-do-set
	(lambda(source) (start-process "set-input-source" nil "macism" source "50000")))
  (sis-ism-lazyman-config

   ;; English input source may be: "ABC", "US" or another one.
   "com.apple.keylayout.ABC"
   ;; "com.apple.keylayout.US"

   ;; Other language input source: "rime", "sogou" or another one.
   "im.rime.inputmethod.Squirrel.Hans"))
   ;;"com.sogou.inputmethod.sogou.pinyin")
  ;; enable the /cursor color/ mode 中英文光标颜色模式
  (sis-global-cursor-color-mode t)
  ;; enable the /respect/ mode buffer 输入法状态记忆模式
  ;; (sis-global-respect-mode t)
  ;; enable the /follow context/ mode for all buffers
  (sis-global-context-mode t)
  ;; enable the /inline english/ mode for all buffers
  (sis-global-inline-mode t) ; 中文输入法状态下，中文后<spc>自动切换英文，结束后自动切回中文
  ;; (global-set-key (kbd "<f9>") 'sis-log-mode) ; 开启日志
  
  (setq sis-inline-tighten-head-rule nil)
  (setq sis-default-cursor-color "brown3")
  (setq sis-other-cursor-color "orange")
  (setq sis-prefix-override-keys (list "C-c" "C-x" "C-h" "C-c e"))
  )
(use-package rime
  :if *is-a-linux*
  :ensure t
   :custom
   (default-input-method "rime")
   (rime-show-candidate 'posframe)
   :config
   (setq rime-user-data-dir "~/.local/share/fcitx5/rime/")
   ;; 临时英文断言
   (setq rime-disable-predicates
         '(meow-normal-mode-p
           rime-predicate-current-input-punctuation-p
           rime-predicate-space-after-cc-p
           rime-predicate-current-uppercase-letter-p
           rime-predicate-tex-math-or-command-p
	   +rime-predicate-org-latex-mode-p
           rime-predicate-after-alphabet-char-p
           rime-predicate-prog-in-code-p)))
(provide 'init-sis)
