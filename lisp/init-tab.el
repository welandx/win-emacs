(use-package sort-tab
  :vc (:fetcher "github" :repo "manateelazycat/sort-tab")
  :defer
  :bind
  ("M-1" . 'sort-tab-select-visible-tab)
  ("M-2" . 'sort-tab-select-visible-tab)
  ("M-3" . 'sort-tab-select-visible-tab)
  ("M-4" . 'sort-tab-select-visible-tab)
  ("M-5" . 'sort-tab-select-visible-tab)
  ("M-6" . 'sort-tab-select-visible-tab)
  ("C-;" . 'sort-tab-close-current-tab)
  :config
  (sort-tab-mode 1))

(defun my-mouse-click-handler (event)
  "处理鼠标点击事件的函数"
  (interactive "e")
  (let* ((window (posn-window (event-start event)))
         (buffer (window-buffer window))
         (pos (posn-point (event-start event))))
    ;; 在这里编写处理鼠标点击事件的代码
    (message "鼠标点击位置：窗口 %s，缓冲区 %s，位置 %s" window buffer pos)))

;; (global-set-key (kbd "M-<mouse-3>") 'my-mouse-click-handler)
;; (define-key sort-tab-mode-map (kbd "M-<mouse-1>") 'my-mouse-click-handler)

(provide 'init-tab)
