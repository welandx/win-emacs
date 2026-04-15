;;; init-telega.el --- Telegram support -*- lexical-binding: t; -*-

(require 'seq)
(require 'nerd-icons)

(defconst my/telega-server-libs-prefixes
  '("/opt/homebrew" "/usr/local" "/usr")
  "Candidate prefixes that might contain telega-server libraries.")

(defun my/telega-server-libs-prefix ()
  "Return the first existing prefix for telega native libraries."
  (seq-find #'file-directory-p my/telega-server-libs-prefixes))

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

  (telega-mode-line-mode 1)
  (if *is-a-mac*
      (telega-notifications-mode -1)
    (telega-notifications-mode 1)))

(provide 'init-telega)
;;; init-telega.el ends here
