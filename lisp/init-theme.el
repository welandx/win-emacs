(setq-default custom-enabled-themes '(ef-day ef-autumn ef-night ef-spring))
(defun reapply-themes ()
  "Forcibly load the themes listed in `custom-enabled-themes'."
  (dolist (theme custom-enabled-themes)
  (unless (custom-theme-p theme)
  (load-theme theme t)))
(custom-set-variables `(custom-enabled-themes (quote ,custom-enabled-themes))))
(add-hook 'after-init-hook 'reapply-themes)

(defun auto-theme-mode-filter (_proc output)
  (let ((current-light-sensor-reading (string-to-number output))
        (current-theme (car custom-enabled-themes))
        (dark-theme 'ef-night)
	(sub-dark-theme 'ef-autumn)
	(sub-light-theme 'ef-spring)
        (light-theme 'ef-day))
    (cond
     ;; ((/= (length output) 10))      ; printf("%8lld", values[0]);
          ((and (< current-light-sensor-reading 70)
                (not (eq current-theme dark-theme)))
           (disable-theme current-theme)
           (enable-theme dark-theme))
          ((and (and (>= current-light-sensor-reading 75)
		     (< current-light-sensor-reading 95))
                (not (eq current-theme sub-dark-theme)))
           (disable-theme current-theme)
           (enable-theme sub-dark-theme))
	  ((and (and (>= current-light-sensor-reading 100)
		     (< current-light-sensor-reading 120))
                (not (eq current-theme sub-light-theme)))
           (disable-theme current-theme)
           (enable-theme sub-light-theme))
	  ((and (>= current-light-sensor-reading 125)
                (not (eq current-theme light-theme)))
           (disable-theme current-theme)
           (enable-theme light-theme))
	  )))

(define-minor-mode auto-theme-mode
  "Automatically set Emacs theme based on ambient light."
  :global t
  (let* ((buf " *auto-theme-mode*")
         (proc (get-buffer-process buf)))
    (if auto-theme-mode
        (or (and proc (eq 'run (process-status proc)))
            (let ((process-connection-type nil))
              (set-process-filter
               (start-process
                "lmutracker"
                buf
                "/bin/sh"
                "-c"
                "while true; do /Users/mengzixian/Documents/mysh/lmutracker && sleep 1; done")
               #'auto-theme-mode-filter)))
      (and proc (kill-process proc)))))
(auto-theme-mode 1)
(provide 'init-theme)
