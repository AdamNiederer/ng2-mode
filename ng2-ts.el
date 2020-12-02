;;; ng2-ts.el --- Major mode for editing Angular 2 TypeScript

;; Copyright 2016-2019 Adam Niederer

;; Author: Adam Niederer <adam.niederer@gmail.com>
;; URL: http://github.com/AdamNiederer/ng2-mode
;; Version: 0.2.3
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
(require 'ng2-shared)

(defconst ng2-ts-name-re
  (concat "\\_<[A-Za-z_$]\\(?:\\s_\\|\\sw\\)*\\_>"))

(defconst ng2-ts-type-name-re
  (concat "\\_<[A-Z_$]\\(?:\\s_\\|\\sw\\)*\\_>"))

(defconst ng2-ts-decorator-re
  (concat "\\(@" ng2-ts-name-re "\\)"))

(defconst ng2-ts-keyword-re
  (ng2--re-opt "is" "infer"))

(defconst ng2-ts-type-keyword-re
  (ng2--re-opt "void" "string" "number" "boolean" "object" "any" "unknown" "never"))

(defconst ng2-ts-interp-re
  "\\(${\\).*?\\(}\\)")

(defconst ng2-ts-type-annotated-re
  (concat "\\(" ng2-ts-name-re "\\)\\s-*[?!]?\\s-*:"))

(defconst ng2-ts-type-re
  (concat
   "\\(?:\\(?:" ng2-ts-type-keyword-re "\\)\\|"
   "\\(?:\\(?:" ng2-ts-type-name-re "\\|" ng2-ts-name-re "\\.\\)*"
   "\\(" ng2-ts-type-name-re "\\)" ; Type name
   "\\(?:\\[\\(" ng2-ts-type-name-re "\\)\\]\\)?\\)\\)")) ; Type subscript

(defconst ng2-ts-type-annotation-re
  (concat ":\\s-*" ng2-ts-type-re "\\s-*"))

(defconst ng2-ts-var-like-search-re
  (concat
   "\\(?:public\\|protected\\|private\\|readonly\\)\\s-+\\("
   "%s" ;; The name of the variable
   "\\)\\s-*[?!]?\\s-*\\(?:[=:].*\\|;?\\)$")) ; Ensure functions don't get picked up

(defconst ng2-ts-var-like-re
  (format ng2-ts-var-like-search-re ng2-ts-name-re))

(defconst ng2-ts-type-arithmetic-re
  (concat "[()]?\\s-*[|&]\\s-*[()]?\\s-*" ng2-ts-type-re "\\s-*"))

(defconst ng2-ts-typedef-re
  (concat "type\\s-\\(" ng2-ts-type-name-re "\\)\\s-*=\\s-*\\(" ng2-ts-type-re "\\)"))

(defconst ng2-ts-postfix-type-like-re
  (concat
   "\\(" ng2-ts-type-re "\\)\\s-+"
   "\\(?:" (ng2--re-opt "implements" "extends")
   "\\|\\(?:in\\|extends\\)\\s-+keyof"
   "\\)"))

(defconst ng2-ts-prefix-type-like-re
  (concat
   (ng2--re-opt "is" "as" "keyof" "instanceof" "infer" "extends" "implements" "class" "interface")
   "\\s-+\\(" ng2-ts-type-re "\\)"))

(defconst ng2-ts-import-default-type-re
  (concat "\\_<import\\s-+\\(" ng2-ts-type-name-re "\\)\\s-+\\(?:as\\s-+\\*\\s-+\\)?from\\_>"))

(defconst ng2-ts-type-condition-re
  (concat
   "extends\\s-+"
   ".+?"
   "\\s-*\\?\\s-*"
   ng2-ts-type-re
   "\\s-*:"))

(defconst ng2-ts-lambda-re
  (concat "=>"))

(defconst ng2-ts-generic-re
  (concat "<" ng2-ts-type-re ".*?>"))

;; -generic-re doesn't match this because it's contained in the .*?
(defconst ng2-ts-inner-generic-re
  (concat "<" ng2-ts-type-re ">"))

(defconst ng2-ts-method-re
  (concat "\\.\\(" ng2-ts-name-re "\\)("))

(defconst ng2-ts-fn-search-re
  (concat
   "\\(%s\\)" ; Function name
   "\\(?:<.*?>\\)?" ; Generic argument
   "([^)]*)\\s-*" ; Argument list
   "\\(?::\\s-*" ng2-ts-type-re "\\)?"; Return type
   "\\(?:<.*?>\\)?\\s-*{"))

(defconst ng2-ts-fn-re
  (format ng2-ts-fn-search-re ng2-ts-name-re))

(defun ng2-ts--inside-import-block-p (pos)
  "Whether POS is inside a Typescript import block."
  (save-match-data
    (and
     (save-excursion
       (goto-char pos)
       (search-backward "{" nil t)
       (forward-symbol -1)
       (looking-at-p "import"))
     (save-excursion
       (goto-char pos)
       (search-forward "}" nil t)
       (forward-symbol 1)
       (forward-symbol -1)
       (looking-at-p "from")))))

(defun ng2-ts--end-of-import (pos)
  "Return the position at the next end of an import statement after POS."
  (save-match-data
    (save-excursion
      (goto-char pos)
      (re-search-forward "}?\\s-*from" nil t)
      (end-of-line)
      (point))))

(defun ng2-ts--highlight-import-block-fn (bound)
  "Match a type inside an import block between point and BOUND."
  (or (when (ng2-ts--inside-import-block-p (point))
        (re-search-forward ng2-ts-type-name-re (min bound (ng2-ts--end-of-import (point))) 1))
      (and (save-match-data (search-forward "{" bound 1))
           (ng2-ts--highlight-import-block-fn bound))))

(defun ng2-ts--inside-lambda-args-p (pos)
  "Return whether POS is inside the arguments to an arrow function."
  (ignore-errors
    (save-match-data
      (<= (save-excursion
            (goto-char pos)
            (search-forward "=>" nil t)
            (backward-sexp)
            (point))
          pos
          (save-excursion
            (goto-char pos)
            (search-forward "=>" nil t)
            (backward-sexp)
            (forward-sexp)
            (1- (point)))))))

(defun ng2-ts--end-of-lambda-args (pos)
  "Return the first end of an arrow function's arguments after POS."
  (save-match-data
    (save-excursion
      (goto-char pos)
      (search-forward "=>" nil t)
      (point))))

(defun ng2-ts--skip-whitespace ()
  "Move POINT past all contiguous whitespace ahead of it."
  (save-match-data (while (looking-at "\\s-\\|\n") (forward-char))))

(defun ng2-ts--highlight-lambda-args-fn (bound)
  "Match a type inside an import block between point and BOUND."
  (or (when (ng2-ts--inside-lambda-args-p (point))
        (re-search-forward (concat "\\(" ng2-ts-name-re "\\)"
                                   "\\(?:\\s-*:\\s-*\\(" ng2-ts-name-re "\\)\\)?"
                                   "\\(?:\\s-*=\\s-*.*?\\(?:[,})]\\|\\]\\)\\)?")
                           (min bound (ng2-ts--end-of-lambda-args (point))) 1))
      (and (ignore-errors
             ;; Fix endless loop on generic return types
             (save-match-data (while (looking-at ">") (forward-char)))
             ;; Skip forward if we wind up in the space between the args and the =>
             (ng2-ts--skip-whitespace)
             (forward-char 2)
             (prog1 (save-match-data (search-forward "=>" bound 1))
               (ignore-errors (backward-sexp))))
           (ng2-ts--highlight-lambda-args-fn bound))))

(defun ng2-ts-goto-name (name)
  "Places the point on the variable or function called NAME."
  (goto-char (point-min))
  (unless (search-forward-regexp (format ng2-ts-fn-search-re name) nil t)
    (unless (search-forward-regexp (format ng2-ts-var-like-search-re name) nil t)
      (message "ng2-ts-mode: Couldn't find %s" name))))

(defvar ng2-ts-mode-map
  (let ((map (make-keymap)))
    (define-key map (kbd "C-c C-o") #'ng2-open-counterpart)
    map)
  "Keymap for ng2-ts-mode.")

(defvar ng2-ts-font-lock-keywords
  `((,ng2-ts-type-condition-re (1 font-lock-type-face nil t))
    (,ng2-ts-type-condition-re (2 font-lock-type-face nil t))
    (,ng2-ts-interp-re . (1 font-lock-variable-name-face t))
    (,ng2-ts-interp-re . (2 font-lock-variable-name-face t))
    (,ng2-ts-type-annotated-re (1 font-lock-variable-name-face))
    (,ng2-ts-type-annotation-re (1 font-lock-type-face nil t))
    (,ng2-ts-type-annotation-re (2 font-lock-type-face nil t))
    (,ng2-ts-type-annotation-re (2 font-lock-type-face nil t))
    (,ng2-ts-type-arithmetic-re (1 font-lock-type-face nil t))
    (,ng2-ts-type-arithmetic-re (2 font-lock-type-face nil t))
    (,ng2-ts-prefix-type-like-re (1 font-lock-type-face nil t))
    (,ng2-ts-prefix-type-like-re (2 font-lock-type-face nil t))
    (,ng2-ts-postfix-type-like-re (1 font-lock-type-face nil t))
    (,ng2-ts-postfix-type-like-re (2 font-lock-type-face nil t))
    (,ng2-ts-import-default-type-re (1 font-lock-type-face))
    (,ng2-ts-var-like-re (1 font-lock-variable-name-face))
    (,ng2-ts-method-re (1 font-lock-function-name-face))
    (,ng2-ts-fn-re (1 font-lock-function-name-face))
    (,ng2-ts-generic-re (1 font-lock-type-face nil t))
    (,ng2-ts-generic-re (2 font-lock-type-face nil t))
    (,ng2-ts-inner-generic-re (1 font-lock-type-face nil t))
    (,ng2-ts-inner-generic-re (2 font-lock-type-face nil t))
    (,ng2-ts-lambda-re (0 font-lock-function-name-face))
    (,ng2-ts-decorator-re (0 font-lock-builtin-face))
    (,ng2-ts-type-keyword-re (0 font-lock-type-face))
    (,ng2-ts-keyword-re (0 font-lock-keyword-face))
    (ng2-ts--highlight-import-block-fn (0 font-lock-type-face))
    (ng2-ts--highlight-lambda-args-fn (1 font-lock-variable-name-face))
    (ng2-ts--highlight-lambda-args-fn (2 font-lock-variable-name-face nil t))))

;;;###autoload
(define-derived-mode ng2-ts-mode
  typescript-mode "ng2-ts"
  "Major mode for Angular 2 TypeScript"
  (modify-syntax-entry ?$ "_" ng2-ts-mode-syntax-table)
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
