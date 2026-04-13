;;; init-org-ai.el --- AI-friendly Org task helpers -*- lexical-binding: t; -*-

(require 'json)
(require 'org)
(require 'org-id)
(require 'subr-x)

(defvar my/org-directory (expand-file-name "~/Documents/org")
  "Root directory for Org notes and agenda files.")

(defconst my/org-ai-inbox-file
  (expand-file-name "inbox.org" my/org-directory)
  "Default file used for AI-captured tasks.")

(defconst my/org-ai-inbox-heading "AI Inbox"
  "Heading used to collect AI-captured tasks.")

(defconst my/org-ai-todo-keywords
  '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)"))
  "TODO keywords used by both interactive Org and batch AI helpers.")

(setq org-todo-keywords my/org-ai-todo-keywords)
(org-set-regexps-and-options)

(defun my/org-ai-agenda-files ()
  "Return agenda-compatible Org files under `my/org-directory'."
  (when (file-directory-p my/org-directory)
    (seq-filter
     (lambda (file)
       (and (not (string-match-p "/\\.?#" file))
            (not (string-match-p "/assets/" file))
            (not (string-match-p "/archive/" file))
            (not (string-match-p "_archive\\.org\\'" file))))
     (directory-files-recursively my/org-directory "\\.org\\'"))))

(defun my/org-ai-refresh-agenda-files ()
  "Refresh `org-agenda-files' from the Org directory."
  (setq org-agenda-files (my/org-ai-agenda-files)))

(defun my/org-ai--ensure-base-file ()
  "Create the default AI inbox file when missing."
  (make-directory my/org-directory t)
  (unless (file-exists-p my/org-ai-inbox-file)
    (with-temp-file my/org-ai-inbox-file
      (insert "#+TITLE: Inbox\n\n* "
              my/org-ai-inbox-heading
              "\n"))))

(defun my/org-ai--ensure-heading (heading)
  "Ensure HEADING exists in `my/org-ai-inbox-file'."
  (my/org-ai--ensure-base-file)
  (with-current-buffer (find-file-noselect my/org-ai-inbox-file)
    (org-with-wide-buffer
      (goto-char (point-min))
      (unless (re-search-forward
               (format "^\\*+ %s\\(?:\\s-.*\\)?$" (regexp-quote heading))
               nil t)
        (goto-char (point-max))
        (unless (bolp)
          (insert "\n"))
        (insert "* " heading "\n")))
    (save-buffer)))

(defun my/org-ai--normalize-tags (tags)
  "Return normalized tag list from TAGS."
  (let* ((raw-tags
          (cond
           ((null tags) nil)
           ((listp tags) tags)
           ((stringp tags) (split-string tags "[ ,:]+" t))
           (t (list (format "%s" tags)))))
         (normalized
          (mapcar (lambda (tag)
                    (downcase (string-trim tag)))
                  raw-tags)))
    (delete-dups
     (seq-filter
      (lambda (tag)
        (not (string-empty-p tag)))
      normalized))))

(defun my/org-ai--format-tags (tags)
  "Format TAGS for an Org heading."
  (let ((normalized (my/org-ai--normalize-tags tags)))
    (if normalized
        (format " :%s:" (string-join normalized ":"))
      "")))

(defun my/org-ai--clean-string (value)
  "Return VALUE as a trimmed string, or nil."
  (when value
    (let ((text (string-trim (format "%s" value))))
      (unless (string-empty-p text)
        text))))

(defun my/org-ai--default-state (schedule deadline)
  "Choose a default TODO state from SCHEDULE and DEADLINE."
  (if (or schedule deadline)
      "NEXT"
    "TODO"))

(defun my/org-ai-capture-task (title &optional note schedule deadline tags state)
  "Capture a task for AI-driven Org workflows.

TITLE is required.  NOTE, SCHEDULE, DEADLINE, TAGS, and STATE are optional.
Return an alist describing the created task."
  (setq title (my/org-ai--clean-string title)
        note (my/org-ai--clean-string note)
        schedule (my/org-ai--clean-string schedule)
        deadline (my/org-ai--clean-string deadline)
        state (upcase (or (my/org-ai--clean-string state)
                          (my/org-ai--default-state schedule deadline))))
  (unless title
    (user-error "Task title is required"))
  (my/org-ai--ensure-heading my/org-ai-inbox-heading)
  (my/org-ai-refresh-agenda-files)
  (with-current-buffer (find-file-noselect my/org-ai-inbox-file)
    (org-with-wide-buffer
      (goto-char (point-min))
      (re-search-forward
       (format "^\\*+ %s\\(?:\\s-.*\\)?$" (regexp-quote my/org-ai-inbox-heading))
       nil t)
      (org-end-of-subtree t t)
      (unless (bolp)
        (insert "\n"))
      (let ((heading-pos (point))
            (all-tags (delete-dups
                       (append '("ai")
                               (my/org-ai--normalize-tags tags)))))
        (insert (format "** %s %s%s\n"
                        state
                        title
                        (my/org-ai--format-tags all-tags)))
        (when note
          (insert note "\n"))
        (save-excursion
          (goto-char heading-pos)
          (org-back-to-heading t)
          (org-id-get-create)
          (org-set-property "CAPTURED_BY" "ai")
          (org-set-property "CREATED_AT"
                            (format-time-string "[%Y-%m-%d %a %H:%M]"))
          (when schedule
            (org-schedule nil schedule))
          (when deadline
            (org-deadline nil deadline)))
        (save-buffer)
        (org-back-to-heading t)
        `((title . ,title)
          (state . ,state)
          (schedule . ,schedule)
          (deadline . ,deadline)
          (file . ,my/org-ai-inbox-file)
          (heading . ,my/org-ai-inbox-heading)
          (id . ,(org-entry-get (point) "ID")))))))

(defun my/org-ai-update-task (id &optional state schedule deadline note)
  "Update an existing task by ID.

Set STATE, SCHEDULE, DEADLINE, and append NOTE when provided.
Return an alist describing the updated task."
  (setq id (my/org-ai--clean-string id)
        state (and state (upcase (my/org-ai--clean-string state)))
        schedule (my/org-ai--clean-string schedule)
        deadline (my/org-ai--clean-string deadline)
        note (my/org-ai--clean-string note))
  (unless id
    (user-error "Task ID is required"))
  (my/org-ai-refresh-agenda-files)
  (org-id-update-id-locations org-agenda-files)
  (let ((marker (org-id-find id 'marker)))
    (unless marker
      (user-error "Task ID not found: %s" id))
    (with-current-buffer (marker-buffer marker)
      (org-with-wide-buffer
        (goto-char marker)
        (org-back-to-heading t)
        (when state
          (org-todo state))
        (when schedule
          (org-schedule nil schedule))
        (when deadline
          (org-deadline nil deadline))
        (when note
          (org-end-of-meta-data t)
          (unless (bolp)
            (insert "\n"))
          (insert note "\n"))
        (save-buffer)
        `((id . ,id)
          (title . ,(org-get-heading t t t t))
          (state . ,(org-get-todo-state))
          (schedule . ,(org-entry-get (point) "SCHEDULED"))
          (deadline . ,(org-entry-get (point) "DEADLINE"))
          (file . ,(buffer-file-name)))))))

(defun my/org-ai--task-record ()
  "Return the current heading as an alist for AI tooling."
  `((id . ,(org-entry-get (point) "ID"))
    (title . ,(org-get-heading t t t t))
    (state . ,(org-get-todo-state))
    (tags . ,(org-get-tags))
    (scheduled . ,(org-entry-get (point) "SCHEDULED"))
    (deadline . ,(org-entry-get (point) "DEADLINE"))
    (file . ,(buffer-file-name))
    (outline_path . ,(org-format-outline-path (org-get-outline-path t) 80 nil " / "))))

(defun my/org-ai-export-open-tasks ()
  "Export all unfinished agenda tasks as JSON."
  (interactive)
  (my/org-ai-refresh-agenda-files)
  (let (items)
    (dolist (file org-agenda-files)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-with-wide-buffer
            (org-map-entries
             (lambda ()
               (let ((state (org-get-todo-state)))
                 (when (and state
                            (not (member state org-done-keywords)))
                   (push (my/org-ai--task-record) items))))
             nil
             'file)))))
    (json-encode (nreverse items))))

(provide 'init-org-ai)
;;; init-org-ai.el ends here
