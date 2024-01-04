(use-package sort-tab
  :vc (:fetcher "github" :repo "manateelazycat/sort-tab")
  :defer 0.1
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


(provide 'init-tab)
