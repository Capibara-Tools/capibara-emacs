; Capibara Emacs Plugin
; Author: Justin Woodring
; Github: https://github.com/Capibara-Tools/capibara-emacs
; Last-Modified 8/22/2024
; License:
;  MIT License
;  
;  Copyright (c) 2024 Justin Woodring
;  
;  Permission is hereby granted, free of charge, to any person obtaining a copy
;  of this software and associated documentation files (the "Software"), to deal
;  in the Software without restriction, including without limitation the rights
;  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;  copies of the Software, and to permit persons to whom the Software is
;  furnished to do so, subject to the following conditions:
;  
;  The above copyright notice and this permission notice shall be included in all
;  copies or substantial portions of the Software.
;  
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;  SOFTWARE.
; Installation:
;
; Put capibara.el in your load-path.
; The load-path is usually ~/elisp/.
;
; Next include capibara in your ~/.emacs startup file like this:
; (add-to-list 'load-path (expand-file-name "~/elisp"))
; (require 'capibara)
; (capibara-default-bindings)

; Vars
;;;###autoload
(setq capiBuf (get-buffer-create " capiBuf"))

; Private Functions

;;;###autoload
(defun --private-capibara-insert-functions (json word)
  "Exhaustively search known functions for a function whose name matches `word`"
  (setq list (gethash "functions" json))
  (dolist (fn list)
    (if (equal word (gethash "name" fn))
	(let* ((header-name (gethash "name" (gethash "header" fn)))
	       (fn-name (gethash "name" fn))
	       (fn-parameters (gethash "parameters" fn))
	       (fn-summary (gethash "summary" fn))
	       (fn-returns (gethash "returns" fn))
	       (fn-environments (gethash "os_affinity" fn))
	       (fn-description (gethash "description" fn)))
	(progn
	  (insert "\n")
	  (insert header-name)
	  (insert "\n")
	  (insert (concat "function " fn-name "("))
	  (dolist (param fn-parameters)
	    (progn
	      (insert (concat "`" (gethash "type" param) "` "))
	      (insert (concat (gethash "name" param) ", "))))
	  (if (not (null fn-parameters)) (delete-backward-char 2))
	  (insert ")")
	  (insert "\n---\n")
          (insert (concat "summary: " fn-summary))
	  (insert "\n---\n")
	  (insert (concat "returns: "
			  "`" (gethash "type" fn-returns) "`"
			  " - " (gethash "description" fn-returns)))
          (insert "\n---\n")
	  (insert "parameters: ")
	  (dolist (param fn-parameters)
	      (insert (concat "\n   - " (gethash "name" param) ": `" (gethash "type" param) "` - " (gethash "description" param))))
	  (insert "\n---\n")
	  (insert "environments: ")
	  (dolist (env fn-environments)
	    (insert (concat env " ")))
	  (insert "\n---\n")
	  (insert (concat "description: \n"
			  (replace-regexp-in-string "\n\n" "\n \n" 
			  (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
			   (replace-regexp-in-string "\n-" "\n\n  *" fn-description)))))
	  (insert "\n---\n")
	  )))))

;;;###autoload
(defun --private-capibara-insert-enums (json word)
  "Exhaustively search known enums for an enum whose name matches `word`"
  (setq list (gethash "enums" json))
  (dolist (enum list)
    (if (equal word (gethash "name" enum))
        (let* ((header-name (gethash "name" (gethash "header" enum)))
               (enum-name (gethash "name" enum))
               (enum-variants (gethash "variants" enum))
               (enum-summary (gethash "summary" enum))
               (enum-environments (gethash "os_affinity" enum))
               (enum-description (gethash "description" enum)))
        (progn
          (insert "\n")
          (insert header-name)
          (insert "\n")
          (insert (concat "enum " enum-name))
          (insert "\n---\n")
          (insert (concat "summary: " enum-summary))
          (insert "\n---\n")
          (insert "variants: ")
          (dolist (variant enum-variants)
              (insert (concat "\n   - " (gethash "name" variant) ":  " (gethash "description" variant))))
          (insert "\n---\n")
          (insert "environments: ")
          (dolist (env enum-environments)
            (insert (concat env " ")))
          (insert "\n---\n")
          (insert (concat "description: \n"
                          (replace-regexp-in-string "\n\n" "\n \n"
                          (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                           (replace-regexp-in-string "\n-" "\n\n  *" enum-description)))))
          (insert "\n---\n")
          )))))

;;;###autoload
(defun --private-capibara-insert-structs (json word)
  "Exhaustively search known structs for an struct whose name matches `word`"
  (setq list (gethash "structs" json))
  (dolist (struct list)
    (if (equal word (gethash "name" struct))
        (let* ((header-name (gethash "name" (gethash "header" struct)))
               (struct-name (gethash "name" struct))
               (struct-fields (gethash "fields" struct))
               (struct-summary (gethash "summary" struct))
               (struct-environments (gethash "os_affinity" struct))
               (struct-description (gethash "description" struct)))
        (progn
          (insert "\n")
          (insert header-name)
          (insert "\n")
          (insert (concat "struct " struct-name))
          (insert "\n---\n")
          (insert (concat "summary: " struct-summary))
          (insert "\n---\n")
          (insert "fields: ")
          (dolist (field struct-fields)
              (insert (concat "\n   - " (gethash "name" field) ": `" (gethash "type" field) "` - " (gethash "description" field))))
          (insert "\n---\n")
          (insert "environments: ")
          (dolist (env struct-environments)
            (insert (concat env " ")))
          (insert "\n---\n")
          (insert (concat "description: \n"
                          (replace-regexp-in-string "\n\n" "\n \n"
                          (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                           (replace-regexp-in-string "\n-" "\n\n  *" struct-description)))))
          (insert "\n---\n")
          )))))

;;;###autoload
(defun --private-capibara-insert-macros (json word)
  "Exhaustively search known macros for an macro whose name matches `word`"
  (setq list (gethash "macros" json))
  (dolist (macro list)
    (if (equal word (gethash "name" macro))
        (let* ((header-name (gethash "name" (gethash "header" macro)))
               (macro-name (gethash "name" macro))
               (macro-kind (gethash "kind" macro))
               (macro-kind-function (gethash "function" macro-kind))
               (macro-parameters (if (not (null macro-kind-function)) (gethash "parameters" macro-kind-function)))
               (macro-summary (gethash "summary" macro))
               (macro-returns (if (not (null macro-kind-function)) (gethash "returns" macro-kind-function)))
               (macro-environments (gethash "os_affinity" macro))
               (macro-description (gethash "description" macro)))
        (progn
          (insert "\n")
          (insert header-name)
          (insert "\n")
          (if (not (null macro-kind-function))
            (progn
              (insert (concat "macro (function-like) " macro-name "("))
              (dolist (param macro-parameters)
                (progn
                  (insert (concat (gethash "name" param) ", "))))
              (if (not (null macro-parameters)) (delete-backward-char 2))
              (insert ")"))
            (progn
              (insert (concat "macro (object-like) " macro-name))))
          (insert "\n---\n")
          (insert (concat "summary: " macro-summary))
          (insert "\n---\n")
          (if (not (null macro-kind-function))
            (progn
              (insert (concat "returns: "
                "`" (gethash "type" macro-returns) "`"
                " - " (gethash "description" macro-returns)))
              (insert "\n---\n")
              (insert "parameters: ")
                (dolist (param macro-parameters)
                  (insert (concat "\n   - " (gethash "name" param) ":  - " (gethash "description" param))))
              (insert "\n---\n")))
          (insert "environments: ")
          (dolist (env macro-environments)
            (insert (concat env " ")))
          (insert "\n---\n")
          (insert (concat "description: \n"
                          (replace-regexp-in-string "\n\n" "\n \n"
                          (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                           (replace-regexp-in-string "\n-" "\n\n  *" macro-description)))))
          (insert "\n---\n")
          )))))

;;;###autoload
(defun --private-capibara-insert-typedefs (json word)
  "Exhaustively search known typedefs for an typedef whose name matches `word`"
  (setq list (gethash "typedefs" json))
  (dolist (typedef list)
    (if (equal word (gethash "name" typedef))
        (let* ((header-name (gethash "name" (gethash "header" typedef)))
               (typedef-name (gethash "name" typedef))
               (typedef-type (gethash "type" typedef))
               (typedef-summary (gethash "summary" typedef))
               (typedef-associated-ref (gethash "associated_ref" typedef))
               (enum (gethash "enum" typedef-associated-ref))
               (enum-header-name (if (not (null enum)) (gethash "name" (gethash "header" enum))))
               (enum-name (if (not (null enum)) (gethash "name" enum)))
               (enum-variants (if (not (null enum)) (gethash "variants" enum)))
               (enum-summary (if (not (null enum)) (gethash "summary" enum)))
               (enum-environments (if (not (null enum)) (gethash "os_affinity" enum)))
               (enum-description (if (not (null enum)) (gethash "description" enum)))
               (struct (gethash "struct" typedef-associated-ref))
               (struct-header-name (if (not (null struct)) (gethash "name" (gethash "header" struct))))
               (struct-name (if (not (null struct)) (gethash "name" struct)))
               (struct-fields (if (not (null struct)) (gethash "fields" struct)))
               (struct-summary (if (not (null struct)) (gethash "summary" struct)))
               (struct-environments (if (not (null struct)) (gethash "os_affinity" struct)))
               (struct-description (if (not (null struct)) (gethash "description" struct)))
               (typedef-environments (gethash "os_affinity" typedef))
               (typedef-description (gethash "description" typedef)))
        (progn
          (insert "\n")
          (insert header-name)
          (insert "\n")
          (insert (concat "typedef " typedef-name " " typedef-type))
          (insert "\n---\n")
          (insert (concat "summary: " typedef-summary))
          (insert "\n---\n")
          (insert (concat "type: " typedef-type))
          (insert "\n---\n")
          (insert "linked type definition:")
          (if (not (null enum))
            (progn
              (insert "\n###\n")
              (insert enum-header-name)
              (insert "\n")
              (insert (concat "enum " enum-name))
              (insert "\n---\n")
              (insert (concat "summary: " enum-summary))
              (insert "\n---\n")
              (insert "variants: ")
              (dolist (variant enum-variants)
                  (insert (concat "\n   - " (gethash "name" variant) ":  " (gethash "description" variant))))
              (insert "\n---\n")
              (insert "environments: ")
              (dolist (env enum-environments)
                (insert (concat env " ")))
              (insert "\n---\n")
              (insert (concat "description: \n"
                              (replace-regexp-in-string "\n\n" "\n \n"
                              (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                              (replace-regexp-in-string "\n-" "\n\n  *" enum-description)))))
              (insert "\n---\n")
              (insert "###\n"))
            (if (not (null struct))
              (progn 
                (insert "\n###\n")
                (insert struct-header-name)
                (insert "\n")
                (insert (concat "struct " struct-name))
                (insert "\n---\n")
                (insert (concat "summary: " struct-summary))
                (insert "\n---\n")
                (insert "fields: ")
                (dolist (field struct-fields)
                    (insert (concat "\n   - " (gethash "name" field) ": `" (gethash "type" field) "` - " (gethash "description" field))))
                (insert "\n---\n")
                (insert "environments: ")
                (dolist (env struct-environments)
                  (insert (concat env " ")))
                (insert "\n---\n")
                (insert (concat "description: \n"
                                (replace-regexp-in-string "\n\n" "\n \n"
                                (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                                (replace-regexp-in-string "\n-" "\n\n  *" struct-description)))))
                (insert "\n---\n")
                (insert "###\n"))
              (insert "\nNo linked type definition\n")))
          (insert "\n---\n")
          (insert "environments: ")
          (dolist (env typedef-environments)
            (insert (concat env " ")))
          (insert "\n---\n")
          (insert (concat "description: \n"
                          (replace-regexp-in-string "\n\n" "\n \n"
                          (replace-regexp-in-string "([^\n])\n([^\n])" "\1 \2"
                           (replace-regexp-in-string "\n-" "\n\n  *" typedef-description)))))
          (insert "\n---\n")
          )))))

; Public Functions
;;;###autoload
(defun capibara-refresh-definitions ()
  "Call this function to download or refresh the local capibara documentation cache"
  (url-copy-file
     "https://capibara.tools/capibara.json"
     (expand-file-name "~/.emacs-capibara-definitions.json")
     :true))

;;;###autoload
(defun capibara-lookup (word)
  "Call this function to readout and display a buffer based on a given word search"
  (pop-to-buffer capiBuf)
  (setq buffer-read-only nil)
  (erase-buffer)
  (let* ((json-object-type 'hash-table)
        (json-array-type 'list)
        (json-key-type 'string)
        (json (json-read-file (expand-file-name "~/.emacs-capibara-definitions.json")))
        (functions (gethash "functions" json)))
    (progn
      (--private-capibara-insert-functions json word)
      (--private-capibara-insert-enums json word)
      (--private-capibara-insert-structs json word)
      (--private-capibara-insert-macros json word)
      (--private-capibara-insert-typedefs json word)
      (if (equal "" (buffer-string)) (insert 
        (concat "Capibara\n---\nNo CAPI definitions found for '" word "'." 
          "\n\nPerhaps your definitions are out of date?"
          "\nTo download new definitions type M-: followed by (capibara-refresh-definitions) and press enter."
          "\n\nIf your definitions are up to date then perhaps you could contribute this definition. "
          "\nTo learn more about contributing to Capibara visit: https://capibara.tools/docs/contribute-docs"
          "\n\nAnd if you're loving this plugin please consider sponsoring it. "
          "\nTo see about and sponsorship information type M-: followed by (capibara-sponsorship) and press enter.")))
      (read-only-mode)
      )))

;;;###autoload
(defun capibara-sponsorship ()
  "Display Capibara sponsorship information."
  (pop-to-buffer capiBuf)
  (setq buffer-read-only nil)
  (erase-buffer)
  (insert (concat
"                                        \n"
"Sponsorship & About:                    \n"
"                                        \n"
"                    ***********         \n"
"                  ,**************.      \n"
"             .*******************       \n"
"         ,******************,.          \n"
"        ********************            \n"
"       ********************             \n"
"       ********************             \n"
"                                        \n"
"                Capibara                \n" 
"                                        \n" 
"----------------------------------------\n"
"  Emacs integration by Justin Woodring  \n"
"                                        \n"
"        Sponsor this plugin at:         \n"
"   github.com/sponsors/JustinWoodring   \n"
"                                        \n"
"      Or contribute to Capibara at:     \n"
"            capibara.tools              \n"
"----------------------------------------\n"))
  )

;;;###autoload
(defun capibara-lookup-cursor ()
  "Bind `capibara-lookup` to F2."
  (interactive)
  (let (word)
    (setq word
          (if (use-region-p)
              (buffer-substring-no-properties (region-beginning) (region-end))
            (current-word)))
    (setq word (replace-regexp-in-string " " "_" word))
    (capibara-lookup word)))

;;;###autoload
(defun capibara-default-bindings ()
  "Bind `capibara-lookup` to F2."
  (interactive)
  (global-set-key (kbd "<f2>") 'capibara-lookup-cursor))

(provide 'capibara)