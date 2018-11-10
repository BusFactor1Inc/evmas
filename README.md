evmas - An Assembler for the Ethereum Virtual Machine (EVM)
==

Evmas is a simple assembler for the EVM written in Common Lisp.

Numbers are automatically pushed onto the stack with the appropriately
sized push instruction.

Strings up to 32 characters are supported and autopushed onto the
stack using the correctly sized push instruction.

Comments are started with semicolon (;).

Files may be included with the .include "<filename>" directive and are
inserted inline into the bytecode stream.

Labels are keywords and thus must be prefixed with a colon (:) and
prefixed by the assembler op .label.  Labels currently take up 4 bytes
in the bytecode stream; I hope to add an optimizer for this in the
future to reduce the byte count on code smaller than 64k, but this
value will be big enough even for the largest of contracts.  Should
this be too big or small, change +jump-label-size+ to a number of
bytes value.

Source files must be ended with the assembler op .end to signal end of
code.

After assembly the Gas cost of the bytecode and the bytecode are
printed. Labels and statistics are printed to Standard Error so the
bytecode can be redirected to a file easily.

Usage
--

```
$ cat test.evm
:main jump

.include "examples/abort.evm" 	;; used by safeAddd
.include "examples/safeAdd.evm"	;; include the safeAdd function
	
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

Debugging
--

```
$ evm --code 5B600A600A016300000023566F74686973206973206120737472696E676300000000565B00 run --debug

0x
#### TRACE ####
JUMPDEST        pc=00000000 gas=10000000000 cost=1

PUSH1           pc=00000001 gas=9999999999 cost=3

PUSH1           pc=00000003 gas=9999999996 cost=3
Stack:
00000000  000000000000000000000000000000000000000000000000000000000000000a

ADD             pc=00000005 gas=9999999993 cost=3
Stack:
00000000  000000000000000000000000000000000000000000000000000000000000000a
00000001  000000000000000000000000000000000000000000000000000000000000000a

PUSH4           pc=00000006 gas=9999999990 cost=3
Stack:
00000000  0000000000000000000000000000000000000000000000000000000000000014

JUMP            pc=00000011 gas=9999999987 cost=8
Stack:
00000000  0000000000000000000000000000000000000000000000000000000000000023
00000001  0000000000000000000000000000000000000000000000000000000000000014

JUMPDEST        pc=00000035 gas=9999999979 cost=1
Stack:
00000000  0000000000000000000000000000000000000000000000000000000000000014

STOP            pc=00000036 gas=9999999978 cost=0
Stack:
00000000  0000000000000000000000000000000000000000000000000000000000000014

#### LOGS ####
```

Supported Instructions
--

An EVM instruction set reference can be found here:

https://gist.github.com/hayeah/bd37a123c02fecffbe629bf98a8391df

Another useful reference with instruction descriptions can be found here:

https://solidity.readthedocs.io/en/v0.4.25/assembly.html


Building
--

Building evmas requires SBCL to be installed: https://sbcl.org.

On MacOS you can use brew: ```brew install sbcl```

Then use the following command to build evmas:	

```
$ sh build.sh
```

Evmas should also work with with other lisps (clisp, ecl, etc) with a
different 'build' command.

Function Selector Generator
--

To be compatible wit the Ethereum ABI, I have included the a function
signature generator.  Use 'npm install' to install its dependencies.
See the ABI docs and examples for more details.

Security
--

Read time evaluation is disabled by default for safety and security.
Use the assembler ops .enable-read-eval! and .disable-read-eval! to
enable/disable sharp dot (#.(...)) evaluation.

TODO:

-- some sort of lispy macro'ish support of sort

--

Burton Samograd

BusFactor1 Inc. - 2018
