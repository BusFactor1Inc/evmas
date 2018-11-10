#!/bin/bash
	
./evmas < ${1-test.evm} | ./evm-disassemble
