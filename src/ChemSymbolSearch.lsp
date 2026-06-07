;;; ChemSymbolSearch.lsp
;;; AutoCAD chemical process DWG library search and insert tool.
;;; Load with APPLOAD, then run HGSYM.

(vl-load-com)

(setq *hgsym-root* nil)
(setq *hgsym-index* nil)
(setq *hgsym-last-query* "")
(setq *hgsym-max-results* 500)
(if (not (boundp '*hgsym-plugin-file*))
  (setq *hgsym-plugin-file* nil)
)

(defun hgsym--slash (s)
  (if s (vl-string-translate "/" "\\" s) "")
)

(defun hgsym--trim-slash (s)
  (if (and s (> (strlen s) 0) (= (substr s (strlen s) 1) "\\"))
    (substr s 1 (1- (strlen s)))
    s
  )
)

(defun hgsym--dirname (path / n pos ch)
  (setq path (hgsym--slash path))
  (setq n (strlen path) pos nil)
  (while (> n 0)
    (setq ch (substr path n 1))
    (if (and (not pos) (= ch "\\"))
      (setq pos n)
    )
    (setq n (1- n))
  )
  (if pos (substr path 1 (1- pos)) "")
)

(defun hgsym--parent (path)
  (hgsym--dirname path)
)

(defun hgsym--library-child (dir / candidate)
  (if dir
    (progn
      (setq candidate (strcat (hgsym--trim-slash (hgsym--slash dir)) "\\Library"))
      (if (vl-file-directory-p candidate) candidate nil)
    )
    nil
  )
)

(defun hgsym--load-path ()
  (cond
    ((and (boundp '*load-pathname*) *load-pathname*) *load-pathname*)
    (*hgsym-plugin-file* *hgsym-plugin-file*)
    ((findfile "ChemSymbolSearch.lsp") (findfile "ChemSymbolSearch.lsp"))
    (T nil)
  )
)

(defun hgsym--local-config-file (/ lsp)
  (setq lsp (hgsym--load-path))
  (if lsp
    (strcat (hgsym--dirname lsp) "\\ChemSymbolSearch.root")
    nil
  )
)

(defun hgsym--config-file (/ appdata)
  (setq appdata (getenv "APPDATA"))
  (if appdata
    (strcat (hgsym--trim-slash (hgsym--slash appdata)) "\\Autodesk\\ApplicationPlugins\\ChemSymbolSearch.root")
    nil
  )
)

(defun hgsym--read-root-config-file (cfg / fh line)
  (if (and cfg (findfile cfg))
    (progn
      (setq fh (open cfg "r"))
      (setq line (read-line fh))
      (close fh)
      (if (and line (vl-file-directory-p line))
        (hgsym--prefer-library-root (hgsym--trim-slash (hgsym--slash line)))
        nil
      )
    )
    nil
  )
)

(defun hgsym--read-root-config (/ root)
  (setq root (hgsym--read-root-config-file (hgsym--local-config-file)))
  (if root
    root
    (hgsym--read-root-config-file (hgsym--config-file))
  )
)

(defun hgsym--prefer-library-root (root / library)
  (setq library (hgsym--library-child root))
  (if library library root)
)

(defun hgsym--write-root-config-file (cfg root / fh)
  (if cfg
    (progn
      (setq fh (open cfg "w"))
      (write-line (hgsym--trim-slash (hgsym--slash root)) fh)
      (close fh)
    )
  )
)

(defun hgsym--write-root-config (root)
  (hgsym--write-root-config-file (hgsym--local-config-file) root)
  (hgsym--write-root-config-file (hgsym--config-file) root)
)

(defun hgsym--default-root (/ lsp plugin-dir library parent)
  (cond
    ((hgsym--read-root-config) (hgsym--read-root-config))
    ((setq lsp (hgsym--load-path))
      (setq plugin-dir (hgsym--dirname lsp))
      (setq library (hgsym--library-child plugin-dir))
      (if library
        library
        (progn
          (setq parent (hgsym--parent plugin-dir))
          parent
        )
      )
    )
    (T (getvar "DWGPREFIX"))
  )
)

(defun hgsym--ensure-root ()
  (if (or (not *hgsym-root*) (not (vl-file-directory-p *hgsym-root*)))
    (setq *hgsym-root* (hgsym--default-root))
  )
  (setq *hgsym-root* (hgsym--prefer-library-root *hgsym-root*))
  *hgsym-root*
)

(defun hgsym--lower (s)
  (if s (strcase s T) "")
)

(defun hgsym--contains (hay needle)
  (and (/= needle "") (wcmatch (hgsym--lower hay) (strcat "*" (hgsym--lower needle) "*")))
)

(defun hgsym--split (s sep / out pos token rest step)
  (setq out nil rest s step (strlen sep))
  (while (setq pos (vl-string-search sep rest))
    (setq token (substr rest 1 pos))
    (if (/= token "") (setq out (cons token out)))
    (setq rest (substr rest (+ pos step 1)))
  )
  (if (/= rest "") (setq out (cons rest out)))
  (reverse out)
)

(defun hgsym--normalize-query (query)
  (if query
    (vl-string-translate ",;|/\\" "     " query)
    ""
  )
)

(defun hgsym--tokenize (query / q tokens)
  (setq q (hgsym--normalize-query query))
  (setq tokens (hgsym--split q " "))
  (vl-remove-if '(lambda (x) (= (vl-string-trim " \t\r\n" x) "")) tokens)
)

(defun hgsym--relative (full root / rel)
  (setq root (hgsym--trim-slash (hgsym--slash root)))
  (setq full (hgsym--slash full))
  (setq rel full)
  (if (= (hgsym--lower (substr full 1 (strlen root))) (hgsym--lower root))
    (setq rel (substr full (+ (strlen root) 2)))
  )
  rel
)

(defun hgsym--category (full root / rel p)
  (setq rel (hgsym--relative full root))
  (setq p (vl-string-search "\\" rel))
  (if p (substr rel 1 p) "")
)

(defun hgsym--sub-category (full root / rel parts len)
  (setq rel (hgsym--relative full root))
  (setq parts (hgsym--split rel "\\"))
  (setq len (length parts))
  (if (> len 1)
    (nth (- len 2) parts)
    ""
  )
)

(defun hgsym--scan-dwgs (dir / result files dirs item path)
  (setq result nil)
  (setq files (vl-directory-files dir "*.dwg" 0))
  (foreach item files
    (setq result (cons (strcat (hgsym--trim-slash dir) "\\" item) result))
  )
  (setq dirs (vl-directory-files dir nil -1))
  (foreach item dirs
    (if (not (member item '("." "..")))
      (progn
        (setq path (strcat (hgsym--trim-slash dir) "\\" item))
        (if (vl-file-directory-p path)
          (setq result (append result (hgsym--scan-dwgs path)))
        )
      )
    )
  )
  result
)

(defun hgsym--make-record (path root)
  (list
    (cons 'name (vl-filename-base path))
    (cons 'category (hgsym--category path root))
    (cons 'folder (hgsym--sub-category path root))
    (cons 'path path)
    (cons 'text (strcat (vl-filename-base path) " " (hgsym--category path root) " " (hgsym--sub-category path root) " " path))
  )
)

(defun hgsym--rec (key rec)
  (cdr (assoc key rec))
)

(defun hgsym--build-index (/ root files)
  (setq root (hgsym--ensure-root))
  (if (not (vl-file-directory-p root))
    (progn
      (alert (strcat "Library folder does not exist:\n" root "\n\nRun HGSYMSETROOT and set the DWG library folder."))
      nil
    )
    (progn
      (prompt (strcat "\nScanning DWG library: " root))
      (setq files (hgsym--scan-dwgs root))
      (setq *hgsym-index* (mapcar '(lambda (p) (hgsym--make-record p root)) files))
      (prompt (strcat "\nIndexed " (itoa (length *hgsym-index*)) " DWG files."))
      *hgsym-index*
    )
  )
)

(defun hgsym--score-token (rec token / name folder category text score)
  (setq name (hgsym--rec 'name rec))
  (setq folder (hgsym--rec 'folder rec))
  (setq category (hgsym--rec 'category rec))
  (setq text (hgsym--rec 'text rec))
  (setq score 0)
  (if (hgsym--contains name token) (setq score (+ score 80)))
  (if (hgsym--contains folder token) (setq score (+ score 30)))
  (if (hgsym--contains category token) (setq score (+ score 20)))
  (if (hgsym--contains text token) (setq score (+ score 5)))
  score
)

(defun hgsym--score (rec tokens / total s ok)
  (setq total 0 ok T)
  (foreach token tokens
    (setq s (hgsym--score-token rec token))
    (if (= s 0)
      (setq ok nil)
      (setq total (+ total s))
    )
  )
  (if ok total 0)
)

(defun hgsym--sort-pairs (pairs)
  (vl-sort pairs '(lambda (a b) (> (car a) (car b))))
)

(defun hgsym--search (query / tokens pairs score)
  (if (not *hgsym-index*) (hgsym--build-index))
  (setq tokens (hgsym--tokenize query))
  (if (= (length tokens) 0)
    (setq tokens (list ""))
  )
  (setq pairs nil)
  (foreach rec *hgsym-index*
    (setq score (if (= (car tokens) "") 1 (hgsym--score rec tokens)))
    (if (> score 0)
      (setq pairs (cons (cons score rec) pairs))
    )
  )
  (mapcar 'cdr (hgsym--sort-pairs pairs))
)

(defun hgsym--display (rec / name folder)
  (setq name (hgsym--rec 'name rec))
  (setq folder (hgsym--rec 'folder rec))
  (strcat name "    [" folder "]")
)

(defun hgsym--write-dcl (/ fn fh)
  (setq fn (vl-filename-mktemp "hgsym.dcl"))
  (setq fh (open fn "w"))
  (foreach line
    (list
      "hgsym_dialog : dialog {"
      "  label = \"Chem Symbol Library\";"
      "  : column {"
      "    : edit_box { key = \"query\"; label = \"Search\"; edit_width = 44; }"
      "    : row {"
      "      : button { key = \"do_search\"; label = \"Search\"; is_default = true; }"
      "      : button { key = \"refresh\"; label = \"Reindex\"; }"
      "      : button { key = \"root\"; label = \"Folder\"; }"
      "    }"
      "    : list_box { key = \"results\"; label = \"Results\"; width = 70; height = 18; }"
      "    : text { key = \"status\"; label = \"\"; width = 70; }"
      "    : row {"
      "      : button { key = \"insert\"; label = \"Insert\"; }"
      "      : button { key = \"openfile\"; label = \"Open DWG\"; }"
      "      : cancel_button { label = \"Close\"; }"
      "    }"
      "  }"
      "}"
    )
    (write-line line fh)
  )
  (close fh)
  fn
)

(defun hgsym--fill-list (key records / n rec)
  (start_list key)
  (setq n 0)
  (foreach rec records
    (if (< n *hgsym-max-results*)
      (progn
        (add_list (hgsym--display rec))
        (setq n (1+ n))
      )
    )
  )
  (end_list)
)

(defun hgsym--insert (path)
  (if (and path (findfile path))
    (progn
      (prompt (strcat "\nPick insertion point, X scale, Y scale, and rotation. File: " path))
      (command "_.-INSERT" path pause pause pause)
    )
    (alert (strcat "DWG file not found:\n" path))
  )
)

(defun hgsym--open (path)
  (if (and path (findfile path))
    (command "_.OPEN" path)
    (alert (strcat "DWG file not found:\n" path))
  )
)

(defun hgsym--choose-root (/ dir)
  (setq dir (getfiled "Pick any DWG file in the library" (hgsym--ensure-root) "dwg" 0))
  (if dir
    (progn
      (setq *hgsym-root* (hgsym--dirname dir))
      (setq *hgsym-index* nil)
      (alert (strcat "Temporary library folder:\n" *hgsym-root* "\n\nRun HGSYMSETROOT to set the top library folder if needed."))
    )
  )
)

(defun hgsym--set-results (query / results)
  (setq *hgsym-last-query* query)
  (setq results (hgsym--search query))
  results
)

(defun hgsym--dialog (/ dcl id results selected query idx path action)
  (setq dcl (hgsym--write-dcl))
  (setq id (load_dialog dcl))
  (if (not (new_dialog "hgsym_dialog" id))
    (progn
      (unload_dialog id)
      (vl-file-delete dcl)
      (alert "Cannot open search dialog.")
      nil
    )
    (progn
      (if (not *hgsym-index*) (hgsym--build-index))
      (setq query *hgsym-last-query*)
      (set_tile "query" query)
      (setq results (hgsym--search query))
      (hgsym--fill-list "results" results)
      (set_tile "status" (strcat "Folder: " (hgsym--ensure-root) "    DWG: " (itoa (length *hgsym-index*))))
      (action_tile "do_search"
        "(setq selected nil) (setq query (get_tile \"query\")) (setq results (hgsym--set-results query)) (hgsym--fill-list \"results\" results) (set_tile \"status\" (strcat \"Found \" (itoa (length results)) \" results\"))"
      )
      (action_tile "query"
        "(setq selected nil) (setq query $value) (setq results (hgsym--set-results query)) (hgsym--fill-list \"results\" results) (set_tile \"status\" (strcat \"Found \" (itoa (length results)) \" results\"))"
      )
      (action_tile "results" "(setq selected $value)")
      (action_tile "refresh"
        "(setq selected nil) (setq *hgsym-index* nil) (hgsym--build-index) (setq results (hgsym--search (get_tile \"query\"))) (hgsym--fill-list \"results\" results) (set_tile \"status\" (strcat \"Reindexed \" (itoa (length *hgsym-index*)) \" DWG files\"))"
      )
      (action_tile "root" "(done_dialog 3)")
      (action_tile "insert" "(done_dialog 1)")
      (action_tile "openfile" "(done_dialog 2)")
      (setq action (start_dialog))
      (unload_dialog id)
      (vl-file-delete dcl)
      (cond
        ((= action 3)
          (hgsym--choose-root)
          (hgsym--dialog)
        )
        ((or (= action 1) (= action 2))
          (if results
            (progn
              (setq idx (if selected (atoi selected) 0))
              (setq path (hgsym--rec 'path (nth idx results)))
              (if (= action 1) (hgsym--insert path) (hgsym--open path))
            )
            (alert "No result selected.")
          )
        )
      )
    )
  )
)

(defun c:HGSYM ()
  (hgsym--ensure-root)
  (hgsym--dialog)
  (princ)
)

(defun c:HGSYMREINDEX ()
  (setq *hgsym-index* nil)
  (hgsym--build-index)
  (princ)
)

(defun hgsym--print-results (records / i rec)
  (setq i 1)
  (foreach rec records
    (if (<= i 30)
      (progn
        (prompt
          (strcat
            "\n"
            (itoa i)
            ". "
            (hgsym--rec 'name rec)
            " ["
            (hgsym--rec 'folder rec)
            "]"
          )
        )
      )
    )
    (setq i (1+ i))
  )
)

(defun c:HGSYMFIND (/ query results count picked rec)
  (hgsym--ensure-root)
  (if (not *hgsym-index*) (hgsym--build-index))
  (setq query (getstring T "\nSearch symbol: "))
  (setq results (hgsym--search query))
  (setq count (length results))
  (prompt (strcat "\nFound " (itoa count) " result(s). Showing first 30."))
  (hgsym--print-results results)
  (if (> count 0)
    (progn
      (setq picked (getint "\nInsert result number <0 to cancel>: "))
      (if (and picked (> picked 0) (<= picked count))
        (progn
          (setq rec (nth (1- picked) results))
          (hgsym--insert (hgsym--rec 'path rec))
        )
      )
    )
  )
  (princ)
)

(defun c:HGSYMINFO ()
  (hgsym--ensure-root)
  (if (not *hgsym-index*) (hgsym--build-index))
  (prompt (strcat "\nLibrary folder: " *hgsym-root*))
  (prompt (strcat "\nIndexed DWG files: " (itoa (length *hgsym-index*))))
  (prompt "\nCommands: HGSYM, HGSYMFIND, HGSYMREINDEX, HGSYMSETROOT, HGSYMROOT, HGSYMHELP")
  (princ)
)

(defun c:HGSYMHELP ()
  (prompt "\nChemSymbolSearch commands:")
  (prompt "\n  HGSYM       - open search dialog")
  (prompt "\n  HGSYMFIND   - command-line search and insert")
  (prompt "\n  HGSYMINFO   - show library path and DWG count")
  (prompt "\n  HGSYMREINDEX - rebuild DWG index")
  (prompt "\n  HGSYMSETROOT - set library folder")
  (prompt "\n  HGSYMROOT   - show library folder")
  (princ)
)

(defun c:HGSYMSETROOT (/ dir library)
  (setq dir (getstring T "\nEnter DWG library root folder: "))
  (if (and dir (/= dir "") (vl-file-directory-p dir))
    (progn
      (setq *hgsym-root* (hgsym--trim-slash (hgsym--slash dir)))
      (setq library (hgsym--library-child *hgsym-root*))
      (if library (setq *hgsym-root* library))
      (setq *hgsym-index* nil)
      (hgsym--write-root-config *hgsym-root*)
      (prompt (strcat "\nLibrary folder set to: " *hgsym-root*))
    )
    (alert "Invalid folder. Paste the full DWG library folder path and try again.")
  )
  (princ)
)

(defun c:HGSYMROOT ()
  (prompt (strcat "\nCurrent library folder: " (hgsym--ensure-root)))
  (princ)
)

(prompt "\nChemSymbolSearch loaded. Run HGSYMINFO, HGSYM, or HGSYMFIND.")
(princ)
