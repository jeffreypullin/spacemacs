;;; packages.el --- ESS (R) Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq ess-packages
  '(
    ess
    ess-R-data-view
    ess-smart-equals
    golden-ratio
    org))

(defun ess/init-ess ()
  (use-package ess-site
    :mode (("\\.sp\\'"           . S-mode)
           ("/R/.*\\.q\\'"       . R-mode)
           ("\\.[qsS]\\'"        . S-mode)
           ("\\.ssc\\'"          . S-mode)
           ("\\.SSC\\'"          . S-mode)
           ("\\.[rR]\\'"         . R-mode)
           ("\\.[rR]nw\\'"       . Rnw-mode)
           ("\\.[sS]nw\\'"       . Snw-mode)
           ("\\.[rR]profile\\'"  . R-mode)
           ("NAMESPACE\\'"       . R-mode)
           ("CITATION\\'"        . R-mode)
           ("\\.omg\\'"          . omegahat-mode)
           ("\\.hat\\'"          . omegahat-mode)
           ("\\.lsp\\'"          . XLS-mode)
           ("\\.do\\'"           . STA-mode)
           ("\\.ado\\'"          . STA-mode)
           ("\\.[Ss][Aa][Ss]\\'" . SAS-mode)
           ("\\.jl\\'"           . ess-julia-mode)
           ("\\.[Ss]t\\'"        . S-transcript-mode)
           ("\\.Sout"            . S-transcript-mode)
           ("\\.[Rr]out"         . R-transcript-mode)
           ("\\.Rd\\'"           . Rd-mode)
           ("\\.[Bb][Uu][Gg]\\'" . ess-bugs-mode)
           ("\\.[Bb][Oo][Gg]\\'" . ess-bugs-mode)
           ("\\.[Bb][Mm][Dd]\\'" . ess-bugs-mode)
           ("\\.[Jj][Aa][Gg]\\'" . ess-jags-mode)
           ("\\.[Jj][Oo][Gg]\\'" . ess-jags-mode)
           ("\\.[Jj][Mm][Dd]\\'" . ess-jags-mode))
    :commands (R stata julia SAS)
    :init
    (progn
      (spacemacs/register-repl 'ess-site 'julia)
      (spacemacs/register-repl 'ess-site 'R)
      (spacemacs/register-repl 'ess-site 'SAS)
      (spacemacs/register-repl 'ess-site 'stata)
      ;; Explicitly run prog-mode hooks since ess-mode does not derive from
      ;; prog-mode major-mode
      (add-hook 'ess-mode-hook 'spacemacs/run-prog-mode-hooks)
      (when (configuration-layer/package-usedp 'company)
          (add-hook 'ess-mode-hook 'company-mode))))

  ;; R --------------------------------------------------------------------------
  (with-eval-after-load 'ess-site
    ;; Follow Hadley Wickham's R style guide
    (setq ess-first-continued-statement-offset 2
          ess-continued-statement-offset 0
          ess-expression-offset 2
          ess-nuke-trailing-whitespace-p t
          ess-default-style 'DEFAULT)

    (defun spacemacs/ess-start-repl ()
      "Start a REPL corresponding to the ess-language of the current buffer."
      (interactive)
      (cond
       ((string= "S" ess-language) (call-interactively 'R))
       ((string= "STA" ess-language) (call-interactively 'stata))
       ((string= "SAS" ess-language) (call-interactively 'SAS))))

    (spacemacs/declare-prefix-for-mode 'ess-mode "md" "package dev")
    (spacemacs/declare-prefix-for-mode 'ess-mode "mh" "help")
    (spacemacs/declare-prefix-for-mode 'ess-mode "mv" "view data")
    (spacemacs/declare-prefix-for-mode 'ess-mode "ms" "session (REPL)")
    (spacemacs/declare-prefix-for-mode 'ess-mode "mc" "chunks")

    (spacemacs/set-leader-keys-for-major-mode 'ess-julia-mode
      "'"  'julia
      "si" 'julia)
    (spacemacs/set-leader-keys-for-major-mode 'ess-mode
      "'"  'spacemacs/ess-start-repl
      "si" 'spacemacs/ess-start-repl
      ;; noweb
      "cC" 'ess-eval-chunk-and-go
      "cc" 'ess-eval-chunk
      "cd" 'ess-eval-chunk-and-step
      "cm" 'ess-noweb-mark-chunk
      "cN" 'ess-noweb-previous-chunk
      "cn" 'ess-noweb-next-chunk
      ;; REPL
      "sB" 'ess-eval-buffer-and-go
      "sb" 'ess-eval-buffer
      "e" 'ess-eval-function-or-paragraph-and-step
      "r"  'ess-eval-word
      "R" 'ess-eval-region
      "sd" 'ess-eval-region-or-line-and-step
      "sL" 'ess-eval-line-and-go
      "sl" 'ess-eval-line
      "sR" 'ess-eval-region-and-go
      "sr" 'ess-eval-region
      "sT" 'ess-eval-function-and-go
      "st" 'ess-eval-function
      ;; R data viewers
      "vd" 'ess-R-dv-pprint
      "vt" 'ess-R-dv-ctable
      ;; Package Dev helpers
      "di" 'ess-r-devtools-install-package
      "dt" 'ess-r-devtools-test-package
      "dl" 'ess-r-devtools-load-package
      "dc" 'ess-r-devtools-check-package
      "dd" 'ess-r-devtools-document-package
      "df" 'ess-roxy-update-entry
      ;; R help
      "ho" 'ess-display-help-on-object
      "hi" 'ess-display-index
      "ha" 'ess-display-help-apropos
      )
    (define-key ess-mode-map (kbd "<s-return>") 'ess-eval-line)
    (define-key inferior-ess-mode-map (kbd "C-j") 'comint-next-input)
    (define-key inferior-ess-mode-map (kbd "C-k") 'comint-previous-input)
    ;; Toggle underscore off no replacement of _ for <-
    (setq ess-smart-S-assign-key nil)
    ;; Stop R repl eval from blocking emacs.
    (setq ess-eval-visibly 'nowait)

    ;; =====================================================================
    ;; Tidyverse IDE
    ;; =====================================================================
    (defun tide-insert-pipe ()
      "Insert a %>% and newline"
      (interactive)
      (insert "%>%")
      (newline-and-indent))
    (defun tide-insert-assign ()
      "Insert an assignment <-"
      (interactive)
      (insert "<- "))
    (define-key ess-mode-map (kbd "C-'") 'tide-insert-pipe)
    (define-key ess-mode-map (kbd "C-\"") 'tide-insert-assign)

    (defun tide-draft-rmd ()
      "Draft a new Rmd file from a template interactively."
      (interactive)
      (setq rmd-file
            (read-from-minibuffer "Rmd Filename (draft_<date>.Rmd): "
                                  nil nil t t
                                  (format "draft_%s.Rmd"
                                          (string-trim
                                           (shell-command-to-string "date --iso-8601")))))
      (setq rmd-template
            (read-from-minibuffer
             (format "Draft %s from template (mmmisc/basic): " rmd-file)
                                               nil nil t t "mmmisc/basic"))
      (symbol-name rmd-template)
      (string-match "\\([^/]+\\)/\\([^/]+\\)"
                    (symbol-name rmd-template))
      (setq template-pkg
            (substring
             (symbol-name rmd-template)
             (match-beginning 1)
             (match-end 1)))
      (setq template-name
            (substring
             (symbol-name rmd-template)
             (match-beginning 2)
             (match-end 2)))
      (message "Drafting using template %s from package %s" template-name template-pkg)
      (ess-eval-linewise
       (format "rmarkdown::draft(file = \"%s\", template = \"%s\",
                package = \"%s\", edit = FALSE)"
               rmd-file template-name template-pkg))
      )



    ;;======================================================================
    ;; (R) markdown mode
    ;;======================================================================

    ;; Insert a new (empty) chunk to R markdown ============================
    (defun insert-chunk ()
      "Insert chunk environment Rmd sessions."
      (interactive)
      (insert "```{r}\n\n```")
      (forward-line -1)
      )
    ;; key binding
    (global-set-key (kbd "C-c i") 'insert-chunk)

    ;; Mark a word at a point ==============================================
    ;; http://www.emacswiki.org/emacs/ess-edit.el
    (defun ess-edit-word-at-point ()
      (save-excursion
        (buffer-substring
         (+ (point) (skip-chars-backward "a-zA-Z0-9._"))
         (+ (point) (skip-chars-forward "a-zA-Z0-9._")))))
    ;; eval any word where the cursor is (objects, functions, etc)
    (defun ess-eval-word ()
      (interactive)
      (let ((x (ess-edit-word-at-point)))
        (ess-eval-linewise (concat x)))
      )
    ;; key binding
    (define-key ess-mode-map (kbd "C-c r") 'ess-eval-word)
    ))




(defun ess/init-ess-R-data-view ())

(defun ess/init-ess-smart-equals ()
  (use-package ess-smart-equals
    :defer t
    :if ess-enable-smart-equals
    :init
    (progn
      (add-hook 'ess-mode-hook 'ess-smart-equals-mode)
      (add-hook 'inferior-ess-mode-hook 'ess-smart-equals-mode))))

(defun ess/pre-init-golden-ratio ()
  (spacemacs|use-package-add-hook golden-ratio
    :post-config
    (dolist (f '(ess-eval-buffer-and-go
                 ess-eval-function-and-go
                 ess-eval-line-and-go))
      (add-to-list 'golden-ratio-extra-commands f))))

(defun ess/pre-init-org ()
  (spacemacs|use-package-add-hook org
    :post-config (add-to-list 'org-babel-load-languages '(R . t))))
