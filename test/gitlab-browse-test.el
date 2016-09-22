;;; gitlab-browse-test.el --- Tests for Gitlab browsing

;; Copyright (C) 2016 Bryan W. Berry <bryan.berry@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'f)


(defconst gitlab-testsuite-dir
  (f-parent (f-this-file))
  "The testsuite directory.")

(defconst gitlab-source-dir
  (f-parent gitlab-testsuite-dir)
  "The gitlab.el source directory.")

(defconst gitlab-readme
  (f-join gitlab-source-dir "README.md"))

(defconst gitlab-test-helper
  (f-join gitlab-testsuite-dir "test-helper.el"))


(defun helper-select-lines (n)
        (beginning-of-buffer)
        (forward-line n)
        (point)
        (push-mark)
        (setq mark-active t)
        (beginning-of-buffer))

(ert-deftest test-gitlab-visiting-file-buffer ()
  :tags '(browse)
   (let ((buffer-file-name "/foo/bar/gitlab-browse-test.el"))
     (should (gitlab--viewing-filep))))


(ert-deftest test-gitlab-not-visiting-file-buffer ()
  :tags '(browse)
   (let ((buffer-file-name nil))
     (should (null (gitlab--viewing-filep)))))


(ert-deftest test-gitlab-determine-linenum ()
  :tags '(browse)
  (cl-letf (((symbol-function 'use-region-p)
            (lambda () t)))
    (save-excursion
      (let ((buffer (find-file-noselect gitlab-readme)))      
        (set-buffer buffer)
        (helper-select-lines 1)
        (should (s-equals? (gitlab--get-line-nums) "#L1-2"))
        ))))


(ert-deftest test-gitlab-determine-linenum-single ()
  :tags '(browse)
    (save-excursion
      (let ((buffer (find-file-noselect gitlab-readme)))      
        (set-buffer buffer)
        (should (s-equals? (gitlab--get-line-nums) "#L1"))
        )))


(ert-deftest test-gitlab-get-project-group+name ()
  :tags '(browse)
  (cl-letf (((symbol-function 'gitlab--get-origin)
             (lambda () "git@git.example.com:acme/my-emacs-project.git")))
    (should (s-equals? (gitlab--get-project-group+name) "acme/my-emacs-project"))))


(ert-deftest test-gitlab-not-in-repo ()
  :tags '(browse)
  (with-temp-buffer
    (should (null (gitlab--git-repo?)))))



(ert-deftest test-gitlab-get-project-should-error ()
  :tags '(browse)
  (with-temp-buffer
    (should-error (gitlab--get-origin)
                  :type 'gitlab-not-in-repo-error)))


(ert-deftest test-gitlab-get-relative-path ()
  :tags '(browse)
  (let ((buffer (find-file-noselect gitlab-test-helper)))      
        (set-buffer buffer)
        (should (s-equals? (gitlab--get-current-path-relative) "test/test-helper.el"))))


(ert-deftest test-gitlab-get-relative-path-none ()
  (ert-deftest test-gitlab-get-relative-path ()
    :tags '(browse)
       (let ((buffer-file-name nil))
         (should (s-equals? (gitlab--get-current-path-relative) ".")))))


(provide 'gitlab-browse-test)
;;; gitlab-browse-test.el ends here
