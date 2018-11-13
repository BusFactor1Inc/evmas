var waitTill = new Date(new Date().getTime() + 1 * 1000);
while(waitTill > new Date()){}

const fs = require('fs');
const Web3 = require('web3');

var account = process.argv[2];
var destAccount = process.argv[3];
var contractAddress = process.argv[4];
var abiFile = process.argv[5];

if(!account | !contractAddress || !abiFile) {
	console.error("Usage: node testErc20.js <account> <contractAddress> <abiFile>");
	process.exit(1);
}
	
abi = fs.readFileSync(abiFile, 'UTF8');	

// For localhost Ganache
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
	
console.error("Using caller account: " + account);	
console.error("Using destination account: " + destAccount);	
console.error("Using contract address: " + contractAddress);	
console.error("Using abiFile: " + abiFile);	

	
let erc20Contract = new web3.eth.Contract(JSON.parse(abi), contractAddress);

var assert = require('assert');
assert.equal([1,2,3].indexOf(4), -1);
	
function assertAndLog (result) { assert(result); console.log(result); }
function assertNotAndLog (result) { assert(!result); console.log(result); }

function noError (result) { gotErrors &= 0; }
function yesError (err) { gotErrors &= 1; }

// Try to send value to all non-payable functions and ensure errors are happening.
console.error("Testing for non-payability of all functions...",);
var gotErrors = 1;
erc20Contract.methods.name().send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.symbol().send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.decimals().send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.balanceOf(account).send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.transfer(destAccount, 0).send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.transferFrom(account, destAccount ,0).send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.approve(destAccount, 0).send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
erc20Contract.methods.allowance(account, destAccount).send({from: account, gas: 100000, value: 1})
	.then(noError).catch(yesError);
web3.eth.sendTransaction({to: contractAddress, from: account, value: 1})
	.then(noError).catch(yesError);
assert.equal(gotErrors, 1); // ensure errors were thrown on all functions
console.error("PASSED!");	

// Check for accurate values on return of calls	
console.error("Testing for sane return value from constant view functions...",);
console.error("name()",);
erc20Contract.methods.name().call({from: account, gas: 100000})
	.then(x => assert.equal(x, "The BusFactor1 EVM ASM Token"));
console.error("symbol()",);
erc20Contract.methods.symbol().call({from: account, gas: 100000})
	.then(x => assert.equal(x, "BF1"));
console.error("decimals()",);
erc20Contract.methods.decimals().call({from: account, gas: 100000})
	.then(x => assert.equal(x, 0));
console.error("totalSupply()",);
erc20Contract.methods.totalSupply().call({from: account, gas: 100000})
	.then(x => assert.equal(x, 100));
console.error("balanceOf()",);
erc20Contract.methods.balanceOf(account).call({from: account, gas: 300000})
	.then(x => assert.equal(x, 100));
console.error("PASSED!");

//console.error("Testing for calling with incorrect number of arguments...",);
//var gotErrors = 1;
// TODO: This is tricky, need to create raw transactions to do this
//assert.equal(gotErrors, 1); // ensure errors were thrown on all functions
//console.error("PASSED!");	


// Transfer 0 tokens, should return 0	
erc20Contract.methods.transfer(destAccount, 0).send({from: account, gas: 200000})
	.then(x => { assert.equal(x, 0); console.log('here') }).catch(yesError);

// This should cause and error and be caught by ensure-value and revert	
erc20Contract.methods.transfer(destAccount, 101).send({from: account, gas: 200000})
	.then(noError).catch(yesError);
assert.equal(gotErrors, 1);	

// Transfer 2 tokens to the destinationAddress	
var result = erc20Contract.methods.transfer(destAccount, 2).send({from: account, gas: 50000})
.on('receipt', x => { console.log(x)
        erc20Contract.methods.balanceOf(account).call().then(x => { assert(x, 98); console.log(x); });
        erc20Contract.methods.balanceOf(destAccount).call().then(x => { assert(x, 2); console.log(x) });

	// Transfer 2 more tokens to the destinationAddress	
	var result = erc20Contract.methods.transfer(destAccount, 2).send({from: account, gas: 50000})
	.on('receipt', x => { console.log(x)
	        erc20Contract.methods.balanceOf(account).call().then(x => { assert(x, 96); console.log(x); });
	        erc20Contract.methods.balanceOf(destAccount).call().then(x => { assert(x, 4); console.log(x) });
        });


        });

	
	
