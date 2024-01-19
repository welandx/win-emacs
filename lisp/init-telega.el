(use-package telega
  :ensure t
  :bind
  ("C-c t" . telega)
  (:map telega-chat-mode-map
        ("C-o" . telega-sticker-choose-favorite-or-recent))
  :config
  (setq telega-server-libs-prefix "/usr/local/")
  (telega-mode-line-mode 1)
  (if *is-a-mac*
    (telega-notifications-mode -1)
    (telega-notifications-mode 1)))
  (with-eval-after-load 'telega
    ;; (add-hook 'telega-chat-mode-hook
    ;;   (lambda () (setq truncate-lines t)))
    (setq telega-symbols-emojify (assq-delete-all 'checkmark telega-symbols-emojify))
    (setq telega-symbols-emojify (assq-delete-all 'heavy-checkmark telega-symbols-emojify))
    (setq telega-symbol-checkmark (nerd-icons-codicon "nf-cod-check"))
    (setq telega-symbol-heavy-checkmark (nerd-icons-codicon "nf-cod-check_all"))
    (defun my/match-at-point-msg ()
      (interactive)
      (let ((regex (read-string "Type: ")))
        (when (telega-msg-match-p (telega-msg-at) `(contains ,regex))
          (message "yes!"))))
    (defun search-back ()
      (interactive)
      (let ((regex (read-string "Type: ")))
        (setq telega-pre-regex regex)
        (setq mycount 1)
        (while (< mycount 100)
          (telega-button-backward 1)
          (when (telega-msg-match-p (telega-msg-at) `(contains ,regex))
            (message "yes!")
            (setq mycount 99))
          (setq mycount (1+ mycount)))))
    (defun continue-search-back ()
      (interactive)
      (setq mycount 1)
      (while (< mycount 100)
        (telega-button-backward 1 nil :no-error)
        (when (telega-msg-match-p (telega-msg-at) `(contains ,telega-pre-regex))
          (message "yes!")
          (setq mycount 99))
        (setq mycount (1+ mycount))))

    (defun my/search-back ()
      (interactive)
      (let ((regex (read-string "Type: ")))
        (setq telega-pre-regex regex)
        (setq mycount 1)
        (while (< mycount 100)
          (telega-button-backward 1 nil :no-error)
          (when (telega-msg-match-p (telega-msg-at) `(contains ,regex))
            (message "yes!")
            (setq mycount 99))
          (setq mycount (1+ mycount))))))
(when *is-a-mac*
(with-eval-after-load 'telega
  ;;;;;;;;
    ;; ui ;;
  ;;;;;;;;
    (defmacro lucius/telega-ins--aux-inline-reply (&rest body)
      `(telega-ins--aux-inline
         "➦" 'telega-msg-inline-reply
         ,@body))

    (defun lucius/telega-ins--msg-reply-inline (msg)
      "For message MSG insert reply header in case MSG is replying to some message."
      (when-let ((reply-to (plist-get msg :reply_to)))
        (cl-ecase (telega--tl-type reply-to)
          (messageReplyToMessage
            ;; NOTE: Do not show reply inline if replying to thread's root
            ;; message.  If replied message is not instantly available, it
            ;; will be fetched later by the
            ;; `telega-msg--replied-message-fetch'
            (unless (eq (plist-get telega-chatbuf--thread-msg :id)
                      (telega--tl-get msg :reply_to :message_id))
              (let ((replied-msg (telega-msg--replied-message msg)))
                (cond ((or (null replied-msg) (eq replied-msg 'loading))
                        ;; NOTE: replied message will be fetched by the
                        ;; `telega-msg--replied-message-fetch'
                        (lucius/telega-ins--aux-inline-reply
                          (telega-ins-i18n "lng_profile_loading")))
                  ((telega--tl-error-p replied-msg)
                    (lucius/telega-ins--aux-inline-reply
                      (telega-ins--with-face 'telega-shadow
                        (telega-ins (telega-i18n "lng_deleted_message")))))
                  ((telega-msg-match-p replied-msg 'ignored)
                    (lucius/telega-ins--aux-inline-reply
                      (telega-ins--message-ignored replied-msg)))
                  (t
                    (telega-ins--with-props
                      ;; When pressed, then jump to the REPLIED-MSG message
                      (list 'action
                        (lambda (_button)
                          (telega-msg-goto-highlight replied-msg)))
                      (lucius/telega-ins--aux-inline-reply
                        (telega-ins--aux-msg-one-line replied-msg
                          :with-username t
                          :username-face
                          (let* ((sender (telega-msg-sender replied-msg))
                                  (faces (telega-msg-sender-title-faces sender)))
                            (if (and (telega-sender-match-p sender 'me)
                                  (plist-get msg :contains_unread_mention))
                              (append faces '(telega-entity-type-mention))
                              faces))))
                      ))))))

          (messageReplyToStory
            ;; NOTE: If replied story is not instantly available, it will
            ;; be fetched later by the `telega-msg--replied-story-fetch'
            (let ((replied-story (telega-msg--replied-story msg)))
              (cond ((or (null replied-story) (eq replied-story 'loading))
                      ;; NOTE: replied story will be fetched by the
                      ;; `telega-msg--replied-story-fetch'
                      (lucius/telega-ins--aux-inline-reply
                        (telega-ins-i18n "lng_profile_loading")))
                ((or (telega--tl-error-p replied-story)
                   (telega-story-deleted-p replied-story))
                  (lucius/telega-ins--aux-inline-reply
                    (telega-ins--with-face 'telega-shadow
                      (telega-ins (telega-i18n "lng_deleted_story")))))
                (t
                  (telega-ins--with-props
                    ;; When pressed, open the replied story
                    (list 'action
                      (lambda (_button)
                        (telega-story-open replied-story msg)))
                    (lucius/telega-ins--aux-inline-reply
                      (telega-ins--my-story-one-line replied-story msg))
                    )))))
          )))

    (defun lucius/telega-ins--fwd-info-inline (fwd-info)
      "Insert forward info FWD-INFO as one liner."
      (when fwd-info
        (telega-ins--with-props
          ;; When pressed, then jump to original message or show info
          ;; about original sender
          (list 'action
            (lambda (_button) (telega--fwd-info-action fwd-info))
            'help-echo "RET to goto original message")
          (telega-ins--with-attrs  (list :max (- telega-chat-fill-column
                                                (telega-current-column))
                                     :elide t
                                     :elide-trail 8
                                     :face 'telega-msg-inline-forward)
            ;; | Forwarded From:
            (telega-ins "| " "➥: ")
            (let* ((origin (plist-get fwd-info :origin))
                    (sender nil)
                    (from-chat-id (plist-get fwd-info :from_chat_id))
                    (from-chat (when (and from-chat-id (not (zerop from-chat-id)))
                                 (telega-chat-get from-chat-id))))
              ;; Insert forward origin first
              (cl-ecase (telega--tl-type origin)
                (messageForwardOriginChat
                  (setq sender (telega-chat-get (plist-get origin :sender_chat_id)))
                  (telega-ins--msg-sender sender
                    :with-avatar-p t
                    :with-username-p t
                    :with-brackets-p t))

                (messageForwardOriginUser
                  (setq sender (telega-user-get (plist-get origin :sender_user_id)))
                  (telega-ins--msg-sender sender
                    :with-avatar-p t
                    :with-username-p t
                    :with-brackets-p t))

                ((messageForwardOriginHiddenUser messageForwardOriginMessageImport)
                  (telega-ins (telega-tl-str origin :sender_name)))

                (messageForwardOriginChannel
                  (setq sender (telega-chat-get (plist-get origin :chat_id)))
                  (telega-ins--msg-sender sender
                    :with-avatar-p t
                    :with-username-p t
                    :with-brackets-p t)))

              (when-let ((signature (telega-tl-str origin :author_signature)))
                (telega-ins " --" signature))

              (when (and from-chat
                      (not (or (eq sender from-chat)
                             (and (telega-user-p sender)
                               (eq sender (telega-chat-user from-chat))))))
                (telega-ins "→")
                (if telega-chat-show-avatars
                  (telega-ins--image
                    (telega-msg-sender-avatar-image-one-line from-chat))
                  (telega-ins--msg-sender from-chat
                    :with-avatar-p t
                    :with-username-p t
                    :with-brackets-p t))))

            (let ((date (plist-get fwd-info :date)))
              (unless (zerop date)
                (telega-ins " " (telega-i18n "lng_schedule_at") " ")
                (telega-ins--date date)))
            (when telega-msg-heading-whole-line
              (telega-ins "\n")))
          (unless telega-msg-heading-whole-line
            (telega-ins "\n")))
        t))
    ;; ;; 修改 [| In reply to: ] 为 [| ➦: ]
    ;; ;; 因为这个 fwd-info 是个闭包，如果想在 elisp 里用闭包必须开词法作用域
    (advice-add 'telega-ins--msg-reply-inline :override #'lucius/telega-ins--msg-reply-inline)
    ;; 修改 [| Forward from: ] 为 [| ➥: ]
    (advice-add 'telega-ins--fwd-info-inline :override #'lucius/telega-ins--fwd-info-inline)

    ;; avatar
    (setq telega-avatar-workaround-gaps-for '(return t))

    ))
(with-eval-after-load 'telega
  ;; 复制图片
  (defun z/telega-save-file-to-clipboard (msg)
    "Save file at point to clipboard.
NOTE: macOS only."
    (interactive (list (telega-msg-for-interactive)))
    (let ((file (telega-msg--content-file msg)))
      (unless file
        (user-error "No file associated with message"))
      (telega-file--download file 32
        (lambda (dfile)
          (telega-msg-redisplay msg)
          (message "Wait for downloading to finish…")
          (when (telega-file--downloaded-p dfile)
            (let* ((fpath (telega--tl-get dfile :local :path)))
              (shell-command (format "osascript -e 'set the clipboard to POSIX file \"%s\"'" fpath))
              (message (format "File saved to clipboard: %s" fpath))))))))
  (define-key telega-msg-button-map (kbd "C") 'z/telega-save-file-to-clipboard)
  (setq telega-emoji-font-family "Noto Color Emoji")
  (setq telega-emoji-use-images nil))


(provide 'init-telega)
