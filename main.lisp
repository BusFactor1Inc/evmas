(defparameter *nibblecode* ())
(defparameter *current-ip* 0)

(defconstant +jump-label-size+ 4) ;; FIXME: breaks when this is changed

(defun value-to-nibbles (value size)
  (let (code)
    (do* ((data value (ash data -4))
          (nibble (logand data #xF) (logand data #xF))
          (count (* size 2) (decf count)))
         ((= count 0))
      (push nibble code))
    code))
  
(defun emit-bytes (size value)
  (let ((code (value-to-nibbles value size)))
    (push code *nibblecode*)
    (incf *current-ip* size)))

(defun emit-byte (byte)
  (emit-bytes 1 byte))

(defun integer-number-of-bytes (x)
  (max 1 (ceiling (/ (integer-length x) 8))))

(defun emit-number (number)
  (emit-bytes (integer-number-of-bytes number) number))

(defun emit-string (string)
  (assert (<= (length string) 32))
  (let (nibbles)
    (dolist (byte (nreverse
                   (map 'list (lambda (c)
                                (char-code c)) string)))
      (let ((high (ash byte -4))
            (low (logand byte #xf)))
        (push low nibbles)
        (push high nibbles)))
    (push nibbles *nibblecode*)
    (incf *current-ip* (length string))))

(defparameter *instruction-table* (make-hash-table))

(defstruct instruction 
  name opcode gascost)

(defmacro defop (name opcode &optional gascost)
  `(let ((instruction (make-instruction :name ',name
                                        :opcode ,opcode
                                        :gascost ,gascost))) ;
     (setf (gethash ',name *instruction-table*) instruction)))

(defun get-instruction (name)
  (gethash name *instruction-table*))

;; an opcode refernce
;; https://github.com/ethereum/pyethereum/blob/develop/ethereum/opcodes.py#L74

(defop stop	#x0 0)
(defop add	#x1 3)
(defop mul	#x2 5)
(defop sub	#x3 3)
(defop div	#x4 5)
(defop sdiv	#x5 5)
(defop mod	#x6 5)
(defop smod	#x7 5)
(defop addmod	#x8 8)
(defop mulmod	#x9 8)
(defop exp	#xa)
(defop signextend #xb 5)

(defop lt	#x10 3)
(defop gt	#x11 3)
(defop slt	#x12 3)
(defop sgt	#x13 3)
(defop iszero	#x14 3)
(defop and	#x15 3)
(defop or	#x16 3)
(defop xor	#x18 3)
(defop not	#x19 3)
(defop byte	#x1a 3)

(defop sha3	#x20)

(defop address	#x30 2)
(defop balance	#x31)
(defop origin	#x32 2)
(defop caller	#x33 2)
(defop callvalue #x34 2)
(defop calldataload #x35 3)
(defop calldatasize #x36 2)
(defop calldatacopy #x37)
(defop codesize	#x38 2)
(defop codecopy	#x39)
(defop gasprice	#x3a 2)
(defop extcodesize #x3b)
(defop extcodecopy #x3c)

(defop blockhash #x40 20)
(defop coinbase	#x41 2)
(defop timestamp #x42 2)
(defop number	#x43 2)
(defop difficulty #x44 2)
(defop gaslimit #x45 2)

(defop pop	#x50 2)
(defop mload	#x51 3)
(defop mstore	#x52 3)
(defop mstore8	#x53 3)
(defop sload	#x54)
(defop sstore	#x55)
(defop jump	#x56 8)
(defop jumpi	#x57 10)
(defop pc	#x58 2)
(defop msize	#x59 2)
(defop gas	#x5a 2)
(defop jmpdest	#x5b 1)

(defop push1	#x60 3)
(defop push2	#x61 3)
(defop push3	#x62 3)
(defop push4	#x63 3)
(defop push5	#x64 3)
(defop push6	#x65 3)
(defop push7	#x66 3)
(defop push8	#x67 3)
(defop push9	#x68 3)
(defop push10	#x69 3)
(defop push11	#x6a 3)
(defop push12	#x6b 3)
(defop push13	#x6c 3)
(defop push14	#x6d 3)
(defop push15	#x6e 3)
(defop push16	#x6f 3)
(defop push17	#x70 3)
(defop push18	#x71 3)
(defop push19	#x72 3)
(defop push20	#x73 3)
(defop push21	#x74 3)
(defop push22	#x75 3)
(defop push23	#x76 3)
(defop push24	#x77 3)
(defop push25	#x78 3)
(defop push26	#x79 3)
(defop push27	#x7a 3)
(defop push28	#x7b 3)
(defop push29	#x7c 3)
(defop push30	#x7d 3)
(defop push31	#x7e 3)
(defop push32	#x7f 3)

(defop dup1	#x80 3)
(defop dup2	#x81 3)
(defop dup3	#x82 3)
(defop dup4	#x83 3)
(defop dup5	#x84 3)
(defop dup6	#x85 3)
(defop dup7	#x86 3)
(defop dup8	#x87 3)
(defop dup9	#x88 3)
(defop dup10	#x89 3)
(defop dup11	#x8a 3)
(defop dup12	#x8b 3)
(defop dup13	#x8c 3)
(defop dup14	#x8d 3)
(defop dup15	#x8e 3)
(defop dup16	#x8f 3)

(defop swap1	#x90 3)
(defop swap2	#x91 3)
(defop swap3	#x92 3)
(defop swap4	#x93 3)
(defop swap5	#x94 3)
(defop swap6	#x95 3)
(defop swap7	#x96 3)
(defop swap8	#x97 3)
(defop swap9	#x98 3)
(defop swap10	#x99 3)
(defop swap11	#x9a 3)
(defop swap12	#x9b 3)
(defop swap13	#x9c 3)
(defop swap14	#x9d 3)
(defop swap15	#x9e 3)
(defop swap16	#x9f 3)

(defop log0	#xa0)
(defop log1	#xa1)
(defop log2	#xa2)
(defop log3	#xa3)

(defop push	#xb0)
(defop dup	#xb1)
(defop swap	#xb2)

(defop create	#xf0 32000)
(defop call	#xf1 40)
(defop callcode	#xf2 700)
(defop return	#xf3 0)
(defop delegatecall #xf4 700)
(defop callblackbox #xf5 40)

(defop staticcall #xfa 40)

;; (defop revert #xfe 0)

(defop selfdestruct #xff 5000)

(defparameter *labels* ())
(defparameter *defines* ())
(defparameter *macros* ())

(defstruct macro 
  args body)

(defmacro aif (p y &optional n)
  `(let ((it ,p))
     (if it ,y ,n)))

(defun get-opcode (instruction)
  (let ((data (aif (gethash instruction *instruction-table*) it)))
    (unless data
      (format *error-output* "Invalid opcode: ~S~%" instruction)
      (quit))
  
    (instruction-opcode data)))
      

(declaim (ftype(function (list) t) assemble)) ;; forward decleration

(defun auto-push-number (value)
  (let* ((number-of-bytes (integer-number-of-bytes value))
         (pusher (intern (format nil "PUSH~S" number-of-bytes))))
    (emit-byte (instruction-opcode 
                (gethash pusher *instruction-table*)))
    (emit-number value)))

(defun auto-push-string (string)
  (let* ((length (length string))
         (pusher (intern (format nil "PUSH~S" length))))
    (emit-byte (instruction-opcode
                (gethash pusher *instruction-table*)))
    (emit-string string)
))

(defun emit (data)
  (when data ;; ignore nils
    (typecase data
      (symbol
       (aif (gethash data *defines*)
            (typecase it
              (number (auto-push-number it))
              (string (auto-push-string it)))
            (emit-byte (get-opcode data))))
      (number
       (auto-push-number data))
      (string
       (auto-push-string data))))
;  (print data)
;  (print *nibblecode*)
;  (print *current-ip*)
)

(defun scan-for-labels (code)
  (loop
   (unless code (return))
   (let ((instruction (pop code)))
     (case instruction
       (.label
        (let ((label (pop code)))
          (format *error-output* "Definining label: ~S~%" label)
          (setf (gethash label *labels*) *current-ip*)
          (emit-byte (get-opcode 'jmpdest))))
       (t 
        (typecase instruction
          (keyword
           (emit 'push4)
           (emit-bytes +jump-label-size+ #x00000000))
          (t
           (emit instruction))))))))

(defun make-keyword (x)
  (intern (format nil ":~S" x)))

(defun assemble (code)
  (loop
   (unless code (return))

   (let ((instruction (pop code)))
     (case instruction 
       (.label
        (pop code)
        (emit 'jmpdest))
       (t
        (typecase instruction
          (keyword
           (let* ((label instruction)
                  (address (gethash label *labels*)))
             (unless address
               (setf address (gethash (make-keyword label) *labels*))
               (unless address
                 (format *error-output* "~%Error: Unknown label: ~S~%" label)
                 (maphash (lambda (k v)
                            (print k *error-output*)
                            (print v *error-output*)) *labels*)
                 (quit)))
             (emit 'push4)
             (emit-bytes +jump-label-size+ address)))
          (t
           (emit instruction)))))))
   
  (setf *nibblecode* (nreverse *nibblecode*))
  ;(print *nibblecode*)

  (let ((gascost 0))
    (labels ((pack-bytes (nibbles)
               (let (bytes
                     (gascount 0))
                 (loop
                  (unless nibbles
                    (return-from pack-bytes (values (nreverse bytes)
                                                    gascount)))
                  (let* ((nibble0 (pop nibbles))
                         (nibble1 (pop nibbles))
                         (byte (logior (ash nibble0 4) nibble1)))
                    (incf gascount
                          (if (zerop byte) 4 68))
                    (push byte bytes))))))


      (let ((output 
             (with-output-to-string (s)
               (dolist (code *nibblecode*)
                 (multiple-value-bind (bytes gascount) (pack-bytes code)
                   (incf gascost gascount)
                   (dolist (byte bytes)
                     (format s "~2,'0X" byte)))))))
        (print :bytecode-gas-cost *error-output*)
        (print gascost *error-output*)
        (force-output *error-output*)
        
        (print :bytecode *error-output*)
        (fresh-line *error-output*)
        (force-output *error-output*)
        (format t output)
        (fresh-line)))))

(defun no-error-read (s)
    (read s nil))

(defun has-macros (code)
  (dolist (x code)
    (when (gethash x *macros*)
      (return-from has-macros t))))

(defun expand-macro (macro s)
  (let ((body (macro-body macro))
        args)
    (dotimes (i (length (macro-args macro)))
      (push (no-error-read s) args))
    (setf args (nreverse args))

    ;; Substitute arguments
    (mapcar (lambda (name arg)
              (setf body (substitute arg name body)))
            (macro-args macro) args)

    ;; expand definition constants
    (setf body
          (mapcan (lambda (x)
                    (aif (gethash x *defines*)
                         (if (listp it)
                             (reverse it)
                           (list it))
                         (list x))) body))

    
    (format *error-output* "Expanded Macro: ~S" body)
    body))

(defun read-source-file (s)

  (setf *read-eval* nil) ;; disable #.(...), eval during read.
  
  (labels ((include-file (filename)
             (with-open-file (s filename)
               (format *error-output* "~%Including ~S~%" filename)
               (let ((code (read-source-file s)))
                 (format *error-output* "~%Succesfully included ~S~%" filename)
                 code)
               )))
    (let (code)
      (handler-case
          (do ((op (no-error-read s) (no-error-read s)))
              ((and op (eq op '.end)))
            (case op
              (.include
               (setf code (append (include-file (no-error-read s)) code))
               ;(print code)
               )
              (.define
               (let ((name (no-error-read s))
                     (value (no-error-read s)))
                 (format *error-output* "Defining ~S as: ~S~%" name value)
                 (setf (gethash name *defines*) value)))
              (.macro
               (let ((name (no-error-read s))
                     (args (no-error-read s))
                     (body (no-error-read s)))
                 (format *error-output* "Definiing macro ~S with args ~S as: ~S~%"
                         name args body)
                 (setf (gethash name *macros*)
                       (make-macro :args args :body body))))
              (.enable-read-eval!
               (setf *read-eval* t))
              (.disable-read-eval!
               (setf *read-eval* nil))
              (t
               (aif (gethash op *macros*)
                    (setf code (append (reverse (expand-macro it s)) code))
                    (aif (gethash op *defines*)
                         (if (and (listp it) (not (null it)))
                           (setf code (append (reverse it) code))
                           (push op code))
                         (push op code))))))
        (error (e)
          (print :error)
          (princ e)))
      code)))

(defun main (&optional filename)
  (setf *current-ip* 0
        *nibblecode* ()
        *labels* (make-hash-table)
        *defines* (make-hash-table)
        *macros* (make-hash-table)
        )
    
  (let* ((s (if filename (open filename) *standard-input*))
         (code (read-source-file s)))
      
    (setf code (nreverse code))

    (print :scanning-for-labels *error-output*)
    (pprint code *error-output*)
    (fresh-line)
    
    (scan-for-labels code)
    
    ;;(let ((*print-base* 16))
    ;;  (maphash (lambda (k v)
    ;;             (print k)
    ;;             (print v)) *labels*))
    
    (setf *current-ip* 0
          *nibblecode* ())
    
    (assemble code)))
