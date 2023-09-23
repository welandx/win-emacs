(ignore-errors (module-load (expand-file-name"~/.emacs.d/site-lisp/pop_select/pop_select.dll")))
(pop-select/transparent-set-all-frame 205)
;; (setq find-program "c:/Users/zwxxm/scoop/apps/msys2/2023-03-18/usr/bin/find.exe")
;; (add-to-list 'exec-path "c:/Users/zwxxm/scoop/apps/msys2/2023-03-18/usr/bin/")
(add-to-list 'exec-path "/cygdrive/c/Users/Administrator/AppData/Local/Microsoft/WinGet/Links/")
(add-to-list 'exec-path "c:/Users/Administrator/AppData/Local/Microsoft/WinGet/Links/")
;; (when (fboundp 'pop-select/beacon-animation)
;;   (add-hook 'post-command-hook (lambda()
;;                                  (ignore-errors
;;                                    (let* ((p (window-absolute-pixel-position))
;;                                           (pp (point))
;;                                           (w (if (equal cursor-type 'bar) 1
;;                                                (if-let ((glyph (when (< pp (point-max))
;;                                                                  (aref (font-get-glyphs (font-at pp) pp (1+ pp)) 0))))
;;                                                    (aref glyph 4)
;;                                                  (window-font-width))))
;;                                           (h (line-pixel-height))
;;                                           )
;;                                      (when p
;;                                        (pop-select/beacon-animation (car p) ; x
;;                                                                     (cdr p) ; y
;;                                                                     w
;;                                                                     h
;;                                                                     100 ; timer
;;                                                                     50 ; timer step
;;                                                                     233 86 120 ; r g b
;;                                                                     )))))))
(provide 'init-win)
