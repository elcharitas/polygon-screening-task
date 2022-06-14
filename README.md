# Polygon Screening Task

> Here lies the polygon screening task by Jonathan Irhodia - The mage known as [elcharitas](https://github.com/elcharitas)

## What's Peer Governor?

> Peer to Peer transactions should be painless and more importantly in our control
>
> \- Jonathan Irhodia

Peer Governor is a smart contract which assists users of the contract(known as peers) to transact(buy or sell) tokens(ERC20, ERC721.. etc).

The governor does this by allowing peers create offers which would include the token they wish to offer up and the one they would love to take up. Another peer can then take up the offer with the requested token.

This format is very similar to those found on platforms like https://binance.com etc.

## How it Works?

- **Peers join by paying a fee**:  This fee is held by the contract which in return gives out peer tokens. The peer token is an ERC20 token which is given to all peers. Peers can trade, exchange, buy or sell with their peer tokens. The governor however, reserves the right to burn those tokens from users wallet when they choose to leave.
- **Peers create offers**: An offer varies from one peer to another. It contains the detail of the token a peer is willing to offer up and the rate(known as price) at which the peer offers. The peer offering is known as the offerer.
- **Peers takes offers**: Once a peer sees an offer that is favorable(for any reason that may be), the peer can take the offer and wait for this newly created take to be accepted by the offerer. This peer is known as the taker. This peer must offer up(within the take) the quoteToken of the offer.
- **Peers accept a take**: Once the offerer sees a take that is favorable(for any reason it is), the peer can accept the take and evidently at this point, both parties get their tokens. The offerer gets the quoteToken while the taker gets the baseToken.

## Is this contract perfect?

> Sadly, NO!

At the time of this writing, there's a lot of ways this contract could be improved and much of which would be added to a TODO in the future.

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
