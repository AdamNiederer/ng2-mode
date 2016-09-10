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

;; The main features of this mode are syntax highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and typescript-mode
;; integration
;;
;; Exported names start with "ng2-ts-"; private names start with
;; "ng2-ts--".

;;; Code:

(defconst ng2-ts-decorator-keywords
  '("@Component"
    "@Directive"
    "@Pipe"
    "@NgModule"))

(defconst ng2-ts-interp-regex
  "${.*?}")

(defconst ng2-ts-var-regex
  "[^?/.] \\(\\w+\\) *[=:]")

(defconst ng2-ts-fn-regex
  "\\(\\w+\\)\(.*\).*{")

(defconst ng2-ts-class-regex
  "class \\(\\w+\\)")

(defconst ng2-ts-lambda-regex
  "\\(\\w+\\) *\\(=>\\)")

(defconst ng2-ts-generic-regex
  "<\\(\\w+\\)\\(\\[\\]\\)?>")

(defcustom ng2-ts-tab-width 2
  "Tab width for ng2-ts-mode"
  :group 'ng2
  :type 'integer)

(defun ng2-ts-goto-fn (fn-name)
  "Places the point on the function called fn-name"
  (beginning-of-buffer)
  (search-forward-regexp (format "\\(\\%s\\)\(.*\).*{" fn-name)))

(defvar ng2-ts-map
  (let ((map (make-keymap)))
    (define-key map (kbd "C-c c") 'ng2-open-counterpart)
    map)
  "Keymap for ng2-ts-mode")

(defvar ng2-ts-font-lock-keywords
  `((,ng2-ts-interp-regex . (0 font-lock-constant-face t))
    (,ng2-ts-var-regex (1 font-lock-variable-name-face))
    (,ng2-ts-class-regex (1 font-lock-type-face))
    (,ng2-ts-fn-regex (1 font-lock-function-name-face))
    (,ng2-ts-generic-regex (1 font-lock-type-face))
    (,ng2-ts-lambda-regex (1 font-lock-variable-name-face))
    (,ng2-ts-lambda-regex (2 font-lock-function-name-face))
    (,(regexp-opt ng2-ts-decorator-keywords) . font-lock-builtin-face)))

;;;###autoload
(define-derived-mode ng2-ts-mode
  typescript-mode "ng2-ts"
  "Major mode for Angular 2 TypeScript"
  (use-local-map ng2-ts-map)
  (setq tab-width ng2-ts-tab-width)
  (font-lock-add-keywords nil ng2-ts-font-lock-keywords))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.component.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.service.ts\\'" . ng2-ts-mode))

(provide 'ng2-ts)
;;; ng2-ts.el ends here
