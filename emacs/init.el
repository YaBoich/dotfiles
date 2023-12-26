;;; package --- Boich Emacs Initialization File

;;; Commentary:

;; Building Emacs from source.
;; Date: 08/10/2023
;; Emacs version 29.1
;; Org version 9.6.6

;; This file does not define the Emacs configuration, rather it loads
;; individual literate config files.  This requires a recent
;; org-version as the built-in version otherwise there can be plenty
;; of issues. Using an 'apt install emacs' type thing, likely won't
;; work with this config. See the README for instructions on building
;; Emacs from source.


;; TODOs:
;; - Enable company and flymake automatically for .el (and other) buffers.
;; - Add flymake hotkeys such as flymake-show-buffer-diagnostics, or whatever.
;; - Add some webdev stuff. Maybe go through some htmx tutorial and see what you need.
;; - I'll need some csharp stuff for work.

;;; Code:
(when (version< emacs-version "29.1")
  (error "This requires Emacs 29.1 and above!"))

(defgroup boich nil
  "Customization group for Boich Emacs settings."
  :prefix "boich/"
  :group 'emacs)

;; TODO: Maybe a 'set' config with all these.
(defcustom boich/line-width 80
  "Default line width to use."
  :type 'int
  :group 'boich)
(setq fill-column boich/line-width)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-language-environment'utf-8)
(set-selection-coding-system 'utf-8)

;; ==============================================================================
;; Config Loading Functionality
;; ==============================================================================

;; ------------------ Lisp Modules ----------------------------------------------
(defcustom boich/lisp-dir (expand-file-name "lisp/" user-emacs-directory)
  "Directory containing lisp config files."
  :type 'directory
  :group 'boich)

(defun update-load-path ()
  "Add lisp config to `load-path`."
  (push boich/lisp-dir load-path))

(update-load-path)

;; ------------------ Literate Org Modules --------------------------------------
(defcustom boich/modules-dir (expand-file-name "modules/" user-emacs-directory)
  "Directory containing configuration modules."
  :type 'directory
  :group 'boich)

(require 'org)
(defun boich/load-module (MODULE)
  "Load config MODULE from modules-dir by fname, expects to receive an org file."
  (org-babel-load-file
   (expand-file-name (concat MODULE ".org") boich/modules-dir)))

(defun boich/load-external (DIR FILE)
  "Load an external org file as literate config. DIR is the directory containing
the file, and FILE is the name of the org file without the '.org' extension."
  (let ((fullpath (expand-file-name (concat FILE ".org") DIR)))
    (if (file-exists-p fullpath)
        (org-babel-load-file fullpath)
      (error "ERROR: Failed to load external module (\"%s\" \"%s\")" DIR FILE))))


;; ==============================================================================
;; Config Loading
;; ==============================================================================

;; ------------------ Lisp Modules ----------------------------------------------
(require 'init-paths)

;; ------------------ Core Modules ----------------------------------------------
(boich/load-module "base")        ;; Runtime paths, Package management, Vim keybindings, Interface.
(boich/load-module "core")        ;; Completion, File & Project Navigation, Helpful features.
(boich/load-module "org")         ;; Core Org Setup, Ricing, Babel, Roam.
(boich/load-module "development") ;; Company completions, Git.

;; ------------------ Personalization -------------------------------------------
(boich/load-module "keybinds")    ;; All keybinds in 1 place.

;; ------------------ Language Specifics ----------------------------------------
(boich/load-module "zig")         ;; Really looking forward to learning this one!

;; ------------------ External Modules ------------------------------------------
(boich/load-external "~/Org/" "README") ;; My Org Mode setup.

;; ------------------ Misc ------------------------------------------------------
(require 'msft)

;; TODO figure out why this keeps re-setting
(setq fill-column boich/line-width)
