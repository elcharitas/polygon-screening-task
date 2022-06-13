# Polygon Screening Task

> Here lies the polygon screening task by Jonathan Irhodia - The mage known as [elcharitas](https://github.com/elcharitas)


## What Lies here?

This repo includes among so many other things:
- an erc20 contract - peer token
- peer governor contract
- a deploy script
- remix config script
- pre-configured tools from hardhat

## Some Interesting Tasks

Try running some of the following tasks:

- compile the contracts
```shell
npx hardhat compile
```
- deploy the contract
```
npx hardhat run scripts/deploy.ts
```
- verify this contract
```
npx hardhat verify --network rinkeby PEER_CONTRACT_ADDRESS
```

## License

> MIT License
