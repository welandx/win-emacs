(set-face-attribute 'default nil :height 80)

;; 设置中文字体大小
(set-fontset-font "fontset-default" 'han (font-spec :family "微软雅黑" :size 80))

(defun sm-scr ()
  (interactive)
  (smooth-cursor-move 40 4))
(local-set-key (kbd "C-o") 'sm-scr)
