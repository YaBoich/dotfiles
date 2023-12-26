;;; init-paths.el --- Runtime path initialization config.

;;; Commentary:

;; We aim to keep our Emacs folder as clean as possible, putting all our
;; generated runtime files and folders in a single directory.  This is really
;; handy - if you wanted to fully reload your Emacs, for example, you can just
;; delete that one folder and open Emacs for what is basically a full
;; re-install.

;;; Code:

;; ----------------- Runtime / Generated Files & Directories -------------------

(defgroup boich/paths nil
  "Customization group for Boich Emacs Path definitions."
  :prefix "boich-paths/"
  :group 'boich)

(defcustom boich/runtime-dir (expand-file-name "runtime/" user-emacs-directory)
  "Base directory for Emacs runetime stored files & directories."
  :type 'directory
  :group 'boich/paths)

(defcustom boich/package-dir (expand-file-name "elpa/" boich/runtime-dir)
  "Directory for packages downloaded from package repos."
  :type 'directory
  :group 'boich/paths)
(setq package-user-dir boich/package-dir)

(with-eval-after-load 'package
  (setq package-gnupghome-dir (expand-file-name "gnupg" boich/package-dir)))

(defcustom boich/custom-file (expand-file-name "custom.el" boich/runtime-dir)
  "Custom file location."
  :type 'file
  :group 'boich/paths)
(setq custom-file boich/custom-file)

;; Create custom file (and directory if required) if it doesn't exist
(let ((dir (file-name-directory custom-file)))
  (unless (file-exists-p dir)
    (make-directory dir t)))
(unless (file-exists-p custom-file)
  (with-temp-file custom-file
    (insert "")))
(load custom-file)

(defcustom boich/auto-save-dir (expand-file-name "auto-saves/" boich/runtime-dir)
  "Single directory for all auto save files."
  :type 'directory
  :group 'boich/paths)
(setq auto-save-file-name-transforms `((".*" ,boich/auto-save-dir t))) ;; auto-save files: #filename#
(setq auto-save-list-file-prefix boich/auto-save-dir)                  ;; auto-save list: .saves-PID-HOSTNAME

(defcustom boich/backup-dir (expand-file-name "backups/" boich/runtime-dir)
  "Directory for all backup files."
  :type 'directory
  :group 'boich/paths)
(setq backup-directory-alist `(("." . ,boich/backup-dir)))

(defcustom boich/transient-history-file (expand-file-name "transient/history.el" boich/runtime-dir)
  "Transient history file location."
  :type 'file
  :group 'boich/paths)
(setq transient-history-file boich/transient-history-file)
;; Have to (require 'transient) to see any of these.
;; TODO - do other transient files when you need to (probably when you start using magit)
;; Just do above require and then go through the C-h v "transient-*-file"

(defcustom boich/undo-tree-dir (expand-file-name "undo-tree/" boich/runtime-dir)
  "Directory for all undo-tree files."
  :type 'directory
  :group 'boich/paths)
(with-eval-after-load 'undo-tree
  (setq undo-tree-history-directory-alist `(("." . ,boich/undo-tree-dir))))

(defcustom boich/desktop-save-dir (expand-file-name "desktop/" boich/runtime-dir)
  "Directory for `desktop-save-mode files."
  :type 'directory
  :group 'boich/paths)
(make-directory boich/desktop-save-dir t)
(setq desktop-dirname boich/desktop-save-dir)

(defcustom boich/recentf-file (expand-file-name "recentf" boich/runtime-dir)
  "Recentf file location."
  :type 'file
  :group 'boich/paths)
(with-eval-after-load 'recentf
  (setq recentf-save-file boich/recentf-file))

(defcustom boich/treemacs-file (expand-file-name ".cache/treemacs-persist" boich/runtime-dir)
  "Treemacs persist file location."
  :type 'file
  :group 'boich/paths)
(with-eval-after-load 'treemacs
  (setq treemacs-persist-file boich/treemacs-file))

(defcustom boich/savehist-file (expand-file-name "savehist" boich/runtime-dir)
  "Savehist file location (keeping track of minibuffer history)."
  :type 'file
  :group 'boich/paths)
(setq savehist-file boich/savehist-file)

(defcustom boich/bookmarks-file (expand-file-name "bookmarks" boich/runtime-dir)
  "Bookmarks file loaction."
  :type 'file
  :group 'boich/paths)
(setq bookmark-default-file boich/bookmarks-file)

(defcustom boich/eln-cache-dir (expand-file-name "eln-cache/" boich/runtime-dir)
  "Native compilation .eln files directory."
  :type 'directory
  :group 'boich/paths)
(setq native-comp-eln-load-path (list boich/eln-cache-dir))

(defcustom boich/org-persist-dir (expand-file-name "org-persist/" boich/runtime-dir)
  "Org-Persist Directory."
  :type 'directory
  :group 'boich/paths)
(setq org-persist-directory boich/org-persist-dir)

(provide 'init-paths)
;;; init-paths.el ends here
