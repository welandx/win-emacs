(defun smooth-cursor-move (x y)
  "Move cursor smoothly to position (X,Y)"
  (let ((dx (- x (current-column)))
        (dy (- y (line-number-at-pos))))
    (while (/= dx 0)
      (let ((step (max 1 (/ (abs dx) 10))))
        (move-to-column (+ (current-column) (* step (signum dx))))
        ;;(sit-for 0.005)
        (sit-for (if (<= (char-after) 127) ; ascii 字符
                     0.02 ; ascii
                   0.5)) ; no-ascii
        )
      (setq dx (- x (current-column))))
    (while (/= dy 0)
      (let ((step (max 1 (/ (abs dy) 10))))
        (goto-line (+ (line-number-at-pos) (* step (signum dy))))
        (sit-for 0.01))
      (setq dy (- y (line-number-at-pos))))))
(defun smooth-cursor-move (x y)
  "Move cursor smoothly to position (X,Y)."
  (let ((dx (- x (current-column)))
        (dy (- y (line-number-at-pos))))
    (while (/= dx 0)
      (move-to-column (+ (current-column) (* 2 (signum dx))))
      (sit-for (if (<= (char-after) 127)
                   0.1
                 1)))
    (setq dx (- x (current-column)))
    (while (/= dy 0)
      (let ((step (max 1 (/ (abs dy) 10)))))
      (goto-line (+ (line-number-at-pos) (* step (signum dy))))
      (sit-for 0.01))
    (setq dy (- y (line-number-at-pos)))))
(defun signum (x)
  "Return the sign of X. If X is positive, return 1. If X is negative, return -1. If X is 0, return 0."
  (cond
   ((> x 0) 1)
   ((< x 0) -1)
   (t 0)))
(defun smooth-cursor-move-horizontal (x)
  "Move cursor smoothly to the horizontal position X."
  (let ((dx (- x (current-column))))
    (move-to-column x)
    (when (/= dx 0)
      (redisplay)
      (move-to-column (+ x (signum dx)))
      (redisplay)
      (move-to-column x))))


(provide 'init-cursor)
