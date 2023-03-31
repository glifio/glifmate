# WELCOME TO GLIFMATE

This repo contains the PoolToken and PreStake contracts. For fuzz testing purposes, we use a `shim` directory to remap to mock contracts that run on Anvil. The `FEVM` shim is the production build.

## Getting started

Make sure you have installed:

[Foundry](https://docs.google.com/document/d/1gaX5ailGE1pAewANUtmjsQTiykH03T2nMbrp4rwamYI/edit?pli=1)<br />
[Yarn](https://yarnpkg.com/)

Make sure the `.env.local` is set up with all variables exported.

PoolToken.sol was compiled with 0.8.17+commit.8df45f5f and 2000000 runs

PreStake.sol was compiled with 0.8.17+commit.8df45f5f and 2000000 runs

PoolToken mainnet:

```
{
  "ActorID": 2097390,
  "RobustAddress": "f2s4fled7kstd343gbzob4harevekx2q4naeurfti",
  "EthAddress": "0x690908f7fa93afC040CFbD9fE1dDd2C2668Aa0e0"
}
```

PreStake mainnet

```

{
  "ActorID": 2097395,
  "RobustAddress": "f23wp4q3xdnopf6xbydjkinsqej423ncyijsykhsi",
  "EthAddress": "0x0ec46ad7aa8600118da4bd64239c3dc364fd0274"
}
```

