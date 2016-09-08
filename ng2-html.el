;;; ng2-html.el --- Major mode for editing Angular 2 templates

;; Copyright 2016 Adam Niederer

;; Author: Adam Niederer <adam.niederer@gmail.com>
;; URL: http://github.com/AdamNiederer/ng2-mode
;; Version: 0.1
;; Keywords: typescript angular angular2
;; Package-Requires: ()

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary

;; The main features of mode is syntactic highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and html-mode
;; integration
;;
;; Exported names start with "ng2-html-"; private names start with
;; "ng2-html--".

;;; Code:

(defgroup angular2-html nil
  "Major mode for AngularJS 2 template files."
  :prefix "ng2-html-"
  :group 'languages
  :link '(url-link :tag "Github" "https://github.com/AdamNiederer/ng2-mode")
  :link '(emacs-commentary-link :tag "Commentary" "ng2-mode"))

(defconst ng2-html-var-regex
  "#\\(.*?\\)=")

(defconst ng2-html-interp-regex
  "{{.*?}}")

(defconst ng2-html-directive-regex
  "\*\\(.*?\\)=")

(defconst ng2-html-binding-regex
  "\\(\\[.*?\\]\\)=\\(\".*?\"\\)")

(defconst ng2-html-event-regex
  "\\((.*?)\\)=\".*?\"")

(defconst ng2-html-pipe-regex
  "{{.*?\\(|\\) *\\(.*?\\) *}}")

(defcustom ng2-html-tab-width 2
  "Tab width for ng2-html-mode"
  :group 'angular2-html
  :type 'integer)

(defvar ng2-html-font-lock-keywords
  `((,ng2-html-var-regex (1 font-lock-variable-name-face))
    (,ng2-html-interp-regex . (0 font-lock-variable-name-face t))
    (,ng2-html-directive-regex . (1 font-lock-keyword-face t))
    (,ng2-html-binding-regex . (1 font-lock-type-face t))
    (,ng2-html-event-regex . (1 font-lock-type-face t))
    (,ng2-html-pipe-regex . (1 font-lock-keyword-face t))
    (,ng2-html-pipe-regex . (2 font-lock-function-name-face t))))

;;;###autoload
(define-derived-mode ng2-html-mode html-mode
  (setq tab-width ng2-html-tab-width)
  (setq major-mode 'ng2-html-mode)
  (setq mode-name "ng2-html")
  (run-hooks 'ng2-html-mode-hook)
  (font-lock-add-keywords nil ng2-html-font-lock-keywords))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.component.html\\'" . ng2-html-mode))

(provide 'ng2-html-mode)
;;; ng2-html.el ends here
