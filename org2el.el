;;; org2el.el --- Convert Org file to Elisp comments  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Junpeng Qiu

;; Author: Junpeng Qiu <qjpchmail@gmail.com>
;; Keywords: extensions

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;                              _____________

;;                                  ORG2EL

;;                               Junpeng Qiu
;;                              _____________


;; Table of Contents
;; _________________

;; 1 Overview
;; 2 Usage
;; 3 Customization


;; Convert `org-mode' file to Elisp comments.


;; 1 Overview
;; ==========

;;   This simple package is mainly used for Elisp package writers. After
;;   you've written the `README.org' for your package, you can use `org2el'
;;   to convert the org file to Elisp comments in the corresponding source
;;   code file.


;; 2 Usage
;; =======

;;   Make sure your source code file has `;;; Commentary:' and `;;; Code:'
;;   lines. The generated comments will be put between these two lines. If
;;   you use `auto-insert', it will take care of generating a standard file
;;   header that contains these two lines in your source code.

;;   In your Org file, invoke `org2el', select the source code file, and
;;   done! Now take a look at your source code file, you can see your Org
;;   file has been converted to the comments in your source code file.


;; 3 Customization
;; ===============

;;   Behind the scenes, this package uses `org-export-as' function and the
;;   default backend is `ascii'. You can change to whatever backend that
;;   your org-mode export engine supports, such as `md' (for markdown):
;;   ,----
;;   | (setq org2el-backend 'md)
;;   `----

;;; Code:

(defvar org2el-backend 'ascii)

(defun org2el--find-bounds (buffer)
  (let (beg end)
    (with-current-buffer buffer
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward "^;;; Commentary:$" nil t)
          (setq beg (line-beginning-position 2))
          (when (re-search-forward "^;;; Code:$")
            (setq end (line-beginning-position))
            (cons beg end)))))))

(defun org2el (file-name)
  (interactive "fSource file: ")
  (let* ((src-buf (find-file-noselect file-name))
         (bounds (org2el--find-bounds src-buf))
         (output (org-export-as org2el-backend))
         beg)
    (if bounds
        (progn
          (with-current-buffer src-buf
            (kill-region (car bounds) (cdr bounds))
            (save-excursion
              (goto-char (car bounds))
              (insert "\n")
              (setq beg (point))
              (insert output)
              (comment-region beg (point))
              (insert "\n")))
          (switch-to-buffer src-buf))
      (error "No \";;; Commentary:\" or \";;; Code:\" found"))))

(provide 'org2el)
;;; org2el.el ends here
