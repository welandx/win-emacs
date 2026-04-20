(require 'treesit)

(setq treesit-language-source-alist
      (append treesit-language-source-alist
              '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
                (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
                (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
                (css "https://github.com/tree-sitter/tree-sitter-css" "master" "src")
                (vue "https://github.com/ikatyang/tree-sitter-vue" "master" "src"))))

(use-package js-ts-mode
  :straight nil
  :mode "\\.js\\'"
  :mode "\\.mjs\\'"
  :mode "\\.cjs\\'"
  :custom
  (js-indent-level 2))

(use-package typescript-ts-mode
  :straight nil
  :mode "\\.ts\\'"
  :custom
  (typescript-ts-mode-indent-offset 2))

(use-package tsx-ts-mode
  :straight nil
  :mode "\\.tsx\\'")

(use-package css-ts-mode
  :straight nil
  :mode "\\.css\\'")

(use-package vue-ts-mode
  :straight (vue-ts-mode :type git
                         :host github
                         :repo "8uff3r/vue-ts-mode")
  :mode "\\.vue\\'"
  :custom
  (vue-ts-mode-indent-offset 2))

(provide 'init-web)
