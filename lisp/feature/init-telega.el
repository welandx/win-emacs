;;; init-telega.el --- Telegram support -*- lexical-binding: t; -*-

(require 'seq)
(require 'nerd-icons)

(defconst my/telega-server-libs-prefixes
  '("/opt/homebrew" "/usr/local" "/usr")
  "Candidate prefixes that might contain telega-server libraries.")

(defun my/telega-server-libs-prefix ()
  "Return the first existing prefix for telega native libraries."
  (seq-find #'file-directory-p my/telega-server-libs-prefixes))

(defcustom my/telega-chatbuf-input-bottom-margin 2
  "Screen lines to keep below the cursor in telega chat input."
  :type 'integer)

(defvar-local my/telega-chatbuf--input-visibility-timer nil)

(defun my/telega-chatbuf--input-buffer-p ()
  "Return non-nil if the current buffer has a telega chat input."
  (and (derived-mode-p 'telega-chat-mode)
       (bound-and-true-p telega-chatbuf--input-marker)))

(defun my/telega-chatbuf--input-point-p (&optional pos)
  "Return non-nil if POS is in the current telega chat input."
  (and (my/telega-chatbuf--input-buffer-p)
       (>= (or pos (point)) telega-chatbuf--input-marker)))

(defun my/telega-chatbuf--recenter-input-in-window (win)
  "Keep WIN from clipping the current telega chat input line."
  (when (and (window-live-p win)
             (eq (window-buffer win) (current-buffer)))
    (with-selected-window win
      (when (my/telega-chatbuf--input-point-p (point))
        (let* ((max-margin (max 1 (1- (window-body-height win))))
               (margin (min max-margin
                            (max 1 my/telega-chatbuf-input-bottom-margin))))
          (recenter (- margin))
          (while (and (< margin max-margin)
                      (not (pos-visible-in-window-p (point) win)))
            (setq margin (1+ margin))
            (recenter (- margin))))))))

(defun my/telega-chatbuf-ensure-input-visible (&optional buffer force)
  "Ensure BUFFER's telega chat input line is fully visible.
If FORCE is non-nil, recenter even when the input line is already visible."
  (when (buffer-live-p (or buffer (current-buffer)))
    (with-current-buffer (or buffer (current-buffer))
      (setq my/telega-chatbuf--input-visibility-timer nil)
      (when (my/telega-chatbuf--input-buffer-p)
        (dolist (win (get-buffer-window-list (current-buffer) nil t))
          (when (my/telega-chatbuf--input-point-p (window-point win))
            (when (or force
                      (not (pos-visible-in-window-p (window-point win) win)))
              (my/telega-chatbuf--recenter-input-in-window win))))))))

(defun my/telega-chatbuf-schedule-input-visibility (&rest _)
  "Schedule a telega chat input visibility check after telega redisplay work."
  (when (my/telega-chatbuf--input-buffer-p)
    (when (timerp my/telega-chatbuf--input-visibility-timer)
      (cancel-timer my/telega-chatbuf--input-visibility-timer))
    (setq my/telega-chatbuf--input-visibility-timer
          (run-at-time nil nil
                       #'my/telega-chatbuf-ensure-input-visible
                       (current-buffer) t))))

(defun my/telega-chatbuf-keep-input-visible ()
  "Keep the current telega chat input line from being clipped."
  (when (my/telega-chatbuf--input-point-p)
    (my/telega-chatbuf-ensure-input-visible)))

(defun my/telega-chatbuf-enable-rime ()
  "Enable Rime input method in telega chat buffers."
  (when *is-a-mac*
    (activate-input-method "rime")))

(defun my/telega-chatbuf-setup ()
  "Set up local telega chat buffer behavior."
  (add-hook 'post-command-hook
            #'my/telega-chatbuf-keep-input-visible nil t)
  (my/telega-chatbuf-enable-rime))

(use-package telega
  :commands (telega)
  :bind
  (("C-c t" . telega)
   :map telega-chat-mode-map
   ("C-o" . telega-sticker-choose-favorite-or-recent))
  :config
  (setq telega-use-images nil)
  (when-let ((prefix (my/telega-server-libs-prefix)))
    (setq telega-server-libs-prefix prefix))

  (setq telega-symbols-emojify
        (assq-delete-all
         'checkmark
         (assq-delete-all 'heavy-checkmark telega-symbols-emojify))
        telega-symbol-checkmark (nerd-icons-codicon "nf-cod-check")
        telega-symbol-heavy-checkmark (nerd-icons-codicon "nf-cod-check_all")
        telega-emoji-use-images nil)

  (when *is-a-mac*
    (setq telega-emoji-font-family "Apple Color Emoji"))

  (add-hook 'telega-chatbuf-post-msg-insert-hook
            #'my/telega-chatbuf-schedule-input-visibility)
  (add-hook 'telega-chatbuf-post-msg-update-hook
            #'my/telega-chatbuf-schedule-input-visibility)
  (add-hook 'telega-chat-mode-hook #'my/telega-chatbuf-setup)

  (telega-mode-line-mode 1)
  (if *is-a-mac*
      (telega-notifications-mode -1)
    (telega-notifications-mode 1)))

(provide 'init-telega)
;;; init-telega.el ends here
