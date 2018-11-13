{ ./evmas < libs/safeMath/testSafeAdd.evm | ./evm-debug 2>&1 | grep REVERT; } && echo passed || echo FAILED
{ ./evmas < libs/safeMath/testSafeSub.evm | ./evm-debug 2>&1 | grep REVERT; } && echo passed || echo FAILED
