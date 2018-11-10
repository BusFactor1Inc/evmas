evmas - An Assembler for the Ethereum Virtual Machine (EVM)
==

Evmas is a simple assembler for the EVM written in Common Lisp.

Labels are keywords and thus must be prefixed with a colon (:) and prefixed by the assembler op .label.

Source files must be ended with the assembler op .end.

After assembly the Gas cost of the bytecode and the bytecode are
printed. Labels and statistics are printed to Standard Error so the
bytecode can be redirected to a file easily.

Usage
--

```
$ cat test.evm
.label :main

10 10 add

:after jump
:main jump

.label :after

stop

.end

$ evmas < test.evm

:BYTECODE-GASCOST 
848 
:BYTECODE 
5B600A600A016300000012566300000000565B00
```

Supported Instructions
--

An EVM instruction set reference can be found here:

https://gist.github.com/hayeah/bd37a123c02fecffbe629bf98a8391df


Building
--

Building evmas requires SBCL to be installed: https://sbcl.org.

On MacOS you can use brew: ```brew install sbcl```

Then use the following command to build evmas:	

```
$ sh build.sh
```

--

Burton Samograd

BusFactor1 Inc. - 2018
