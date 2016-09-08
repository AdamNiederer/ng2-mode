;;; ng2-ts.el --- Major mode for editing Angular 2 TypeScript

;; Copyright 2016 Adam Niederer

;; Author: Adam Niederer <adam.niederer@gmail.com>
;; URL: http://github.com/AdamNiederer/ng2-mode
;; Version: 0.1
;; Keywords: typescript angular angular2
;; Package-Requires: ((typescript-mode "0.1"))

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

;; The main features of mode are syntactic highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and typescript-mode
;; integration
;;
;; Exported names start with "ng2-ts-"; private names start with
;; "ng2-ts--".

;;; Code:

(require 'typescript-mode)

(defgroup angular2-ts nil
  "Major mode for AngularJS 2 TypeScript files."
  :prefix "ng2-ts-"
  :group 'languages
  :link '(url-link :tag "Github" "https://github.com/AdamNiederer/ng2-ts-mode")
  :link '(emacs-commentary-link :tag "Commentary" "ng2-mode"))

(defconst ng2-ts-decorator-keywords
  '("@Component"
    "@Directive"
    "@Pipe"
    "@NgModule"))

(defconst ng2-ts-interp-regex
  "${.*?}")

(defconst ng2-ts-var-regex
  "\\([^ ]\\)\\(\\<\\w*\\>\\)\\( *[=:] *\\)")

(defcustom ng2-ts-tab-width 2
  "Tab width for ng2-ts-mode"
  :group 'angular2-ts
  :type 'integer)

(defvar ng2-ts-font-lock-keywords
  `((,ng2-ts-interp-regex . (0 font-lock-constant-face t))
    (,ng2-ts-var-regex (2 font-lock-variable-name-face))
    (,(regexp-opt ng2-ts-decorator-keywords) . font-lock-builtin-face)))

(define-derived-mode ng2-ts-mode typescript-mode
  (setq tab-width ng2-ts-tab-width)
  (setq major-mode 'ng2-ts-mode)
  (setq mode-name "ng2-ts")
  (run-hooks 'ng2-ts-mode-hook)
  (font-lock-add-keywords nil ng2-ts-font-lock-keywords))

(add-to-list 'auto-mode-alist '("\\.component.ts\\'" . ng2-ts-mode))
(add-to-list 'auto-mode-alist '("\\.service.ts\\'" . ng2-ts-mode))

(provide 'ng2-ts-mode)
;;; ng2-ts.el ends here
