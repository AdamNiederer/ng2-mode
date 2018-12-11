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

;;; Commentary:

;; The main features of this mode are syntax highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and typescript-mode
;; integration
;;
;; Exported names start with "ng2-ts-"; private names start with
;; "ng2-ts--".

;;; Code:

(require 'typescript-mode)

(defconst ng2-ts-decorator-regex
  "\\(@[A-Za-z0-9_]+\\)")

(defconst ng2-ts-type-keywords
  '("void" "string" "number" "boolean" "object" "any"))

(defconst ng2-ts-interp-regex
  "${.*?}")

(defconst ng2-ts-var-regex
  "\\(\\w+\\) *:")

(defconst ng2-ts-type-regex
  "[{,:&] *\\([A-Z]\\w*\\)")

(defconst ng2-ts-class-regex
  "class \\(\\w+\\)")

(defconst ng2-ts-interface-regex
  "implements \\(\\w+\\)")

(defconst ng2-ts-lambda-regex
  "\\(\\w+\\) *\\(=>\\)")

(defconst ng2-ts-generic-regex
  "<\\(\\w+\\)\\(\\[\\]\\)?.*?>")

(defconst ng2-ts-method-regex
  (concat "\\([[]?[a-zA-Z,_0-9]+[]]?\\)"
          "[.]\\([a-zA-Z_0-9]+\\)"
          "([\0-\377[:nonascii:]]*"))

(defconst ng2-ts-fn-regex
  (concat
   "\\([a-zA-Z_0-9]+\\)" ; Function name
   "\\(<.*?>\\)?" ; Generic argument
   "([^)]*)\s-*:?\s-*" ; Argument list
   "\\([a-zA-Z_0-9]*\\)"; Return type
   "\\(<.*?>\\)?\s-*{" ; Generic argument, and opening brace
   ))

(defun ng2-ts-goto-fn (fn-name)
  "Places the point on the function called FN-NAME."
  (goto-char (point-min))
  (search-forward-regexp (format "\\(\\%s\\)\(.*\).*{" fn-name)))

(defvar ng2-ts-mode-map
  (let ((map (make-keymap)))
    (define-key map (kbd "C-c C-o") 'ng2-open-counterpart)
    map)
  "Keymap for ng2-ts-mode.")

(defvar ng2-ts-font-lock-keywords
  `((,ng2-ts-interp-regex . (0 font-lock-constant-face t))
    (,ng2-ts-var-regex (1 font-lock-variable-name-face))
    (,ng2-ts-type-regex (1 font-lock-type-face))
    (,ng2-ts-class-regex (1 font-lock-type-face))
    (,ng2-ts-interface-regex (1 font-lock-type-face))
    (,ng2-ts-method-regex (2 font-lock-function-name-face))
    (,ng2-ts-fn-regex (1 font-lock-function-name-face nil t))
    (,ng2-ts-generic-regex (1 font-lock-type-face))
    (,ng2-ts-lambda-regex (1 font-lock-variable-name-face))
    (,ng2-ts-lambda-regex (2 font-lock-function-name-face))
    (,ng2-ts-decorator-regex (0 font-lock-builtin-face))
    (,(regexp-opt ng2-ts-type-keywords 'words). font-lock-type-face)))

;;;###autoload
(define-derived-mode ng2-ts-mode
  typescript-mode "ng2-ts"
  "Major mode for Angular 2 TypeScript"
  (font-lock-add-keywords nil ng2-ts-font-lock-keywords))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.component.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.service.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.pipe.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.directive.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.guard.ts\\'" . ng2-ts-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.module.ts\\'" . ng2-ts-mode))

(provide 'ng2-ts)
;;; ng2-ts.el ends here
