
;; Trying to get things working on Windows

;; Grep / Ripgrep Here's some things I did:
;; - Install ripgrep `choco install ripgrep`
;; - Add it to windows path: `Get-Command rg`, add output of that to
;;   path environment var.
;; - Use counsel-rg instead of projectile-rg cause it just works?
;; - LMAO?
(setq projectile-use-git-grep t) ; Use this if you want to prioritize
				 ; git-grep in git repos
(setq projectile-generic-command "rg --files --hidden")

(provide 'windows)

