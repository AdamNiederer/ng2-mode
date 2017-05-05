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

;;; Commentary:

;; The main features of this mode are syntax highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and html-mode
;; integration
;;
;; Exported names start with "ng2-html-"; private names start with
;; "ng2-html--".

;;; Code:

(defconst ng2-html-var-regex
  "\\(#\\)\\(\\w+\\)")

(defconst ng2-html-interp-regex
  "{{.*?}}")

(defconst ng2-html-directive-regex
  "\\(\*\\)\\(.*?\\)[\"= ]")

(defconst ng2-html-binding-regex
  "\\(\\[(?\\)\\(.*?\\)\\()?\\]\\)=\\(\".*?\"\\)")

(defconst ng2-html-event-regex
  "\\((\\)\\(.*?\\)\\()\\)=\".*?\"")

(defconst ng2-html-pipe-regex
  "{{.*?\\(|\\) *\\(.*?\\) *}}")

(defun ng2-html-goto-binding ()
  "Opens the corresponding component TypeScript file, then places the cursor at the function corresponding to the binding."
  (interactive)
  (let ((fn-name (word-at-point)))
    (ng2-open-counterpart)
    (ng2-ts-goto-fn fn-name)))

(defvar ng2-html-font-lock-keywords
  `((,ng2-html-var-regex (1 font-lock-builtin-face))
    (,ng2-html-var-regex (2 font-lock-variable-name-face))
    (,ng2-html-interp-regex . (0 font-lock-variable-name-face t))
    (,ng2-html-directive-regex . (1 font-lock-builtin-face t))
    (,ng2-html-directive-regex . (2 font-lock-keyword-face t))
    (,ng2-html-binding-regex . (1 font-lock-builtin-face t))
    (,ng2-html-binding-regex . (2 font-lock-builtin-face t))
    (,ng2-html-binding-regex . (3 font-lock-builtin-face t))
    (,ng2-html-event-regex . (1 font-lock-builtin-face t))
    (,ng2-html-event-regex . (2 font-lock-builtin-face t))
    (,ng2-html-event-regex . (3 font-lock-builtin-face t))
    (,ng2-html-pipe-regex . (1 font-lock-function-name-face t))
    (,ng2-html-pipe-regex . (2 font-lock-function-name-face t))))

(defvar ng2-html-map
  (let ((map (make-keymap)))
    (define-key map (kbd "C-c b") 'ng2-html-goto-binding)
    (define-key map (kbd "C-c c") 'ng2-open-counterpart)
    map)
  "Keymap for ng2-html-mode.")

;;;###autoload
(define-derived-mode ng2-html-mode
  html-mode "ng2-html"
  "Major mode for Angular 2 templates"
  (use-local-map ng2-html-map)
  (font-lock-add-keywords nil ng2-html-font-lock-keywords))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.component.html\\'" . ng2-html-mode))

(provide 'ng2-html)
;;; ng2-html.el ends here
