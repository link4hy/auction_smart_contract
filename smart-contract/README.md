
# Smart contract

This project is orginaly created by XiaoLiu from https://www.linkedin.com/learning/build-an-ethereum-smart-contract-with-go-and-solidity

It demostrates how to use Foundry to compile, test, deploy a smart contract.


## prerequisites
1. Has the Solidity and Foundry installed.

## Build
1. install dependency 
```
   forge install OpenZeppelin/openzeppelin-contracts --no-git
```
2. 
```
forge build
```
3. generate go binding

compile abi
```
> solc --abi src/EnglishAuction.sol -o out/EnglishAuction.sol
```
compile binary
```
> solc --bin src/EnglishAuction.sol -o out/EnglishAuction.sol
```
install abigen
```
> go get -u github.com/ethereum/go-ethereum
```
generate go binding 
```
> abigen --bin=./out/EnglishAuction.sol/EnglishAuction.bin --abi ./out/EnglishAuction.sol/EnglishAuction.abi --pkg=contract --out=out/EnglishAuction.sol/auction.go
```
it will generate aution.go file. which I feel very similar like openAPI schema.

## Deploy the smart contract to local chain.
1. Start the anvil 
```
> anvil
```
2. Deploy NFT contract
Note: the --unlocked only work on local chain. which means no need private key

//wallet address 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```
>forge create --rpc-url 127.0.0.1:8545 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast src/MyNFT.sol:MyNFT --constructor-args 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```
//contract address of NFT after deployed
0x5FbDB2315678afecb367f032d93F642f64180aa3
 
3. mint the NFT
```
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 "safeMint(address, uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 1
```
4. deploy auction contract
```
forge create --rpc-url 127.0.0.1:8545 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast  src/EnglishAuction.sol:EnglishAuction --constructor-args 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```
contract address of Auction after deployed
0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0

5. Approve the contract

it allow auction contract to use NFT contract.
```
cast send  0x5FbDB2315678afecb367f032d93F642f64180aa3 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 "approve(address, uint256)" 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 1
```
6. Start the go app and ready to receive API call


## Deploy the smart contract to test chain.

1. Deploy NFT contract
//sepolia
```
> forge create --rpc-url https://sepolia.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F --broadcast src/MyNFT.sol:MyNFT --constructor-args 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F
```
Deployed to: 0x3A247Ca808814132fC3e457a22e7071193Ee8031 (contract address)(can be search by etherscan)

or 
//Amoy
```
> forge create --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F --broadcast src/MyNFT.sol:MyNFT --constructor-args 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F
```
Deployed to: 0xe083c652CD98E93e3cE3547E3ff4aEf930217229(contract address)


2. mint the NFT (1 amount)
//sepolia
// 1 is the ID of NFT minted, it need to be update if u want mint the second one. 
```
cast send 0x3A247Ca808814132fC3e457a22e7071193Ee8031 --rpc-url https://sepolia.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY  --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "safeMint(address, uint256)" 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F 1
```
//Minted 2 NFT, id=1 and id=2

//Amoy 
// 1 is the ID of NFT minted 
```
cast send 0xe083c652CD98E93e3cE3547E3ff4aEf930217229 --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY  --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "safeMint(address, uint256)" 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F 1
```
//Minted 2 NFT, id=1 and id=2

3. deploy auction contract
//sepolia
//specify the NFT id
```
forge create --rpc-url https://sepolia.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F --broadcast  src/EnglishAuction.sol:EnglishAuction --constructor-args 0x3A247Ca808814132fC3e457a22e7071193Ee8031 1
```
Deployed to: 0x66e08CD388b324C16c06f9c0C68EA3f35aCD059F (contract address)

//Amoy
//specify the NFT id
```
forge create --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F --broadcast  src/EnglishAuction.sol:EnglishAuction --constructor-args 0xe083c652CD98E93e3cE3547E3ff4aEf930217229 1
```
Deployed to: 0x3a553CE863a0a2896E31fD93e286f247B06bf52B (contract address)

//Amoy deploy a new one.
```
forge create --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F --broadcast  src/EnglishAuction.sol:EnglishAuction --constructor-args 0xe083c652CD98E93e3cE3547E3ff4aEf930217229 2
```
Deployed to: 0x6d4A5f3EEDF1C6DAAF2F359Fc471D54Fce38B7E9 (contract address)

4. Approve the contract
//sepolia
//1 is token ID
it allow auction contract to use NFT contract.
```
cast send  0x3A247Ca808814132fC3e457a22e7071193Ee8031 --rpc-url https://sepolia.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "approve(address, uint256)" 0x66e08CD388b324C16c06f9c0C68EA3f35aCD059F 1
```
//Amoy
//1 is token ID
it allow auction contract to use NFT contract.
```
cast send  0xe083c652CD98E93e3cE3547E3ff4aEf930217229 --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "approve(address, uint256)" 0x3a553CE863a0a2896E31fD93e286f247B06bf52B 1
```
//Amoy approve the new acution
```
cast send  0xe083c652CD98E93e3cE3547E3ff4aEf930217229 --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "approve(address, uint256)" 0x6d4A5f3EEDF1C6DAAF2F359Fc471D54Fce38B7E9 2
```
5. test the auction contract (OPTIONAL)
//sepolia
```
cast send 0x66e08CD388b324C16c06f9c0C68EA3f35aCD059F --rpc-url https://sepolia.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY  --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "start(uint, uint)" 100 120
```
//Amoy
```
cast send 0x3a553CE863a0a2896E31fD93e286f247B06bf52B --rpc-url https://polygon-amoy.infura.io/v3/4f14853904b04e6e87d96248c25669a5 --private-key $PRIVATE_KEY  --from 0x25Fa4aA01c270aab0F5e9497aa9E232F12e4A51F "start(uint, uint)" 100 120
```

6. Test the auction contract via web3,js
```
> git clone https://github.com/link4hy/web3js_examples
> node 4_write_smart_contract_english_auction.js
```