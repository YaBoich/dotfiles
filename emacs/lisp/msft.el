
(use-package org-roam-ui)

(defun boich/work-search ()
  (interactive)
  (let ((input (read-string "Enter input: ")))
    (browse-url (concat "https://www.bing.com/work/search?q=" input))))

(provide 'msft)
