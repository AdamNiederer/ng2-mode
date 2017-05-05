;;; ng2-mode.el --- Major modes for editing Angular 2

;; Copyright 2016 Adam Niederer

;; Author: Adam Niederer <adam.niederer@gmail.com>
;; URL: http://github.com/AdamNiederer/ng2-mode
;; Version: 0.1
;; Keywords: typescript angular angular2 template
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

;; The main features of the modes are syntax highlighting (enabled with
;; `font-lock-mode' or `global-font-lock-mode'), and easy switching
;; between templates and components.
;;
;; Exported names start with "ng2-"; private names start with
;; "ng2--".

;;; Code:

(require 'ng2-ts)
(require 'ng2-html)

(defgroup ng2 nil
  "Major mode for AngularJS 2 files"
  :prefix "ng2-"
  :group 'languages
  :link '(url-link :tag "Github" "https://github.com/AdamNiederer/ng2-mode")
  :link '(emacs-commentary-link :tag "Commentary" "ng2-mode"))

(defun ng2--counterpart-name (file)
  "Return the file name of FILE's counterpart, or FILE if there is no counterpart."
  (when (not (ng2--is-component file)) file)
  (let ((ext (file-name-extension file))
        (base (file-name-sans-extension file)))
    (if (equal ext "ts")
        (concat base ".html")
      (concat base ".ts"))))

(defun ng2--sans-type (file)
  "Return the FILE's basename, sans its extensions."
  (file-name-sans-extension (file-name-sans-extension file)))

(defun ng2--is-component (file)
  "Return whether FILE is a component file."
  (equal (file-name-extension (file-name-sans-extension file)) "component"))

(defun ng2-open-counterpart ()
  "Opens the corresponding template or component file to this one."
  (interactive)
  (find-file (ng2--counterpart-name (buffer-file-name))))

;;;###autoload
(defun ng2-mode ()
  "Activates the appropriate Angular 2-related mode for the buffer."
  (interactive)
  (if (equal buffer-file-name nil)
    (message "This doesn't appear to be an Angular2 component or service.")
    (let ((file-ext (file-name-extension (buffer-file-name))))
      (cond
       ((equal file-ext "html") (ng2-html-mode))
       ((equal file-ext "ts") (ng2-ts-mode))
       (t (message "This doesn't appear to be an Angular2 component or service."))))))

(provide 'ng2-mode)
;;; ng2-mode.el ends here
