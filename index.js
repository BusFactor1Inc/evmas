web3 = require ('web3');

console.error(process.argv[2]);
console.log(web3.utils.keccak256(process.argv[2]));
