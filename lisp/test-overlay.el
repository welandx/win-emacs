(setq cursor-overlay (make-overlay 1 1))
(overlay-put cursor-overlay 'face '(:inverse-video t)) ; 设置反色显示
 (overlay-put cursor-overlay 'width 2) ; 设置宽度为 2
 (overlay-put cursor-overlay 'priority 100) ; 设置优先级为 100
