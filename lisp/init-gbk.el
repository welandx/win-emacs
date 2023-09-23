(set-language-environment "UTF-8")
(prefer-coding-system 'gbk)
;; (prefer-coding-system 'utf-8)
;; (set-default 'process-coding-system-alist
;;       '(("[pP][lL][iI][nN][kK]" gbk-dos . gbk-dos)
;;   ("[cC][mM][dD][pP][rR][oO][xX][yY]" gbk-dos . gbk-dos)
;;   ("[gG][sS]" gbk-dos . gbk-dos)))
(add-to-list 'process-coding-system-alist
                        '("[rR][gG]" . (utf-8 . gbk-dos)))

(defun spacemacs/dos2unix ()
  "Converts the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))

(defun spacemacs/unix2dos ()
  "Converts the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))
(setq-default buffer-file-coding-system 'utf-8-unix)

(provide 'init-gbk)
