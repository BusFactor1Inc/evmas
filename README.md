evmas - An Assembler for the Ethereum Virtual Machine (EVM)
==

Evmas is a simple assembler for the EVM written in Common Lisp.

Numbers are automatically pushed onto the stack with the appropriately
sized push instruction.

Strings up to 32 characters are supported and autopushed onto the
stack using the correctly sized push instruction.

Comments are started with semicolon (;).

Labels are keywords and thus must be prefixed with a colon (:) and
prefixed by the assembler op .label.  Labels currently take up 4 bytes
in the bytecode stream; I hope to add an optimizer for this in the
future to reduce the byte count on code smaller than 64k, but this
value will be big enough even for the largest of contracts.  Should
this be too big or small, change +jump-label-size+ to a number of
bytes value.

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

"this is a string" ; autopushed

:main jump

.label :after

stop

.end


$ evmas < test.evm

:BYTECODE-GAS-COST 
2004 
:BYTECODE 
5B600A600A016300000023566F74686973206973206120737472696E676300000000565B00
```

Dissasembly/Verification
--

Assembly can be verified using the following, using evm from the go-ethereum package:

```
$ echo 5B600A600A016300000023566F74686973206973206120737472696E676300000000565B00 > bytecode

$ evm disasm bytecode
5B600A600A016300000023566F74686973206973206120737472696E676300000000565B00
000000: JUMPDEST
000001: PUSH1 0x0a
000003: PUSH1 0x0a
000005: ADD
000006: PUSH4 0x00000023
000011: JUMP
000012: PUSH16 0x74686973206973206120737472696e67
000029: PUSH4 0x00000000
000034: JUMP
000035: JUMPDEST
000036: STOP
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

TODO:

-- add .string for string support

-- add .define for constants

-- some sort of lispy macro'ish support of sort

--

Burton Samograd

BusFactor1 Inc. - 2018
