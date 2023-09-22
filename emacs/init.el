
;; Bootstrap emacs config
(require 'org)
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

;; Load custom Org config (if it exists)
(let ((org-literate-config-file (expand-file-name "README.org" org-directory)))
  (when (file-exists-p org-literate-config-file)
    (org-babel-load-file org-literate-config-file)))
