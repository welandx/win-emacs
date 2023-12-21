(use-package elfeed
  :ensure t
  :bind
  (:prefix-map elfeed-map
	       :prefix "C-c e"
	       ("e" . elfeed)
	       ("u" . elfeed-update)))
(use-package elfeed-org
  :ensure t
  :after elfeed
  :config
  (elfeed-org))

(provide 'news)
