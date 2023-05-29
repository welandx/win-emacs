(let ((my/minor-mode-alist '((flycheck-mode flycheck-mode-line))))
  (setq mode-line-modes
        (mapcar (lambda (elem)
                  (pcase elem
                    (`(:propertize (,_ minor-mode-alist . ,_) . ,_)
                     `(:propertize ("" ,my/minor-mode-alist)
			                       mouse-face mode-line-highlight
			                       local-map ,mode-line-minor-mode-keymap)
                     )
                    (_ elem)))
                mode-line-modes)
        ))

(provide 'init-modeline)
