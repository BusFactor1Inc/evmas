const fs = require('fs');
const Web3 = require('web3');

var address = process.argv[2];
var abiFile = process.argv[3];

if(!address || !abiFile) {
	console.error("Usage: cat bytecode | node deploy.js <address> <abiFile>");
	process.exit(1);
}
	
password = "password";	
bytecode = undefined;

abi = fs.readFileSync(abiFile, 'UTF8');	

// For localhost Ganache
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

process.stdin.on('data', function(chunk) {
	if(chunk) {
		bytecode = chunk.toString().split('\n')[0];
	}
});

var gasPrice = 1;
var gas = 0;
var contractInstance;
	
process.stdin.on('end', function() {
	console.error("Using address: " + address);	
	console.error("Using password: " + password);	
	console.error("Using abiFile: " + abiFile);	
	console.error("Using bytecode: " + bytecode);	

	
	web3.eth.personal.unlockAccount(address, password).
	    then(() => { console.error('Account unlocked.'); }).
	    catch(console.error);

	web3.eth.getGasPrice().
		then((averageGasPrice) => {
	       		console.error("Average gas price: " + averageGasPrice);
	       		gasPrice = averageGasPrice;
	   }).
	
	catch(console.error);
	let contract = new web3.eth.Contract(JSON.parse(abi), null, { 
		  	        	     data: '0x' + bytecode 
	});

	contract.deploy().estimateGas().
		then((estimatedGas) => {
        		console.error("Estimated gas: " + estimatedGas);
	        	gas = estimatedGas;
	}).

	catch(console.error);
	contract.deploy().send({from: address,
				gasPrice: gasPrice, 
				gas: 300000,
	}).then((instance) => { 
		console.error("Contract address:");
		console.log(instance.options.address);
		contractInstance = instance; 
	});
});


