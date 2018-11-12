var waitTill = new Date(new Date().getTime() + 1 * 1000);
while(waitTill > new Date()){}

const fs = require('fs');
const Web3 = require('web3');

var account = process.argv[2];
var contractAddress = process.argv[3];
var abiFile = process.argv[4];

if(!account | !contractAddress || !abiFile) {
	console.error("Usage: node testErc20.js <account> <contractAddress> <abiFile>");
	process.exit(1);
}
	
abi = fs.readFileSync(abiFile, 'UTF8');	

// For localhost Ganache
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
	
console.error("Using contract address: " + contractAddress);	
console.error("Using abiFile: " + abiFile);	

	
let erc20Contract = new web3.eth.Contract(JSON.parse(abi), contractAddress);

// get name	
erc20Contract.methods.name().call({from: account, gas: 100000}).
	then(function (result) { 
	console.log(result);
});

// get symbol
erc20Contract.methods.symbol().call({from: account, gas: 100000})
	.then(function (result) { 
	console.log(result);
});

// get decimals
erc20Contract.methods.decimals().call({from: account, gas: 100000})
	.then(function (result) { 
	console.log(result);
});

// get totalSupply
erc20Contract.methods.totalSupply().call({from: account, gas: 100000})
	.then(function (result) { 
	console.log(result);
});
