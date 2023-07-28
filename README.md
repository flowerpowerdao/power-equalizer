![BP_FPDAO_Logo_BlackOnWhite_sRGB_2](https://user-images.githubusercontent.com/32162112/221128811-5484d430-c357-49e8-8b25-0f04695a5691.svg)

# power equalizer 🌼

## Development
```
npm start
```

Redeploy when you changed Motoko code
```
npm run deploy-local
```

## Steps to launch an NFT collection

- [ ] fork this repository
- [ ] comment out last 4 lines in `.gitignore`
- [ ] prepare and deploy [assets](#assets)
- [ ] copy `initArgs.local.did` to `initArgs.did` and adapt it to your needs (see [INIT_ARGS.md](INIT_ARGS.md))
- [ ] [create canisters](#create-canisters)
- [ ] [deploy NFT canister](#deploy-nft-canister)
- [ ] create collection [summary](https://docs.google.com/document/d/1yady6xdsuInRbj8zLpIn7oG933UZUzg-vx_MUnr_jJ0/edit?usp=sharing)
- [ ] add canister to [DAB](https://docs.google.com/forms/d/e/1FAIpQLSc-0BL9FMRtI0HhWj4g7CCYjf3TMr4_K_qqmagjzkUH_CKczw/viewform)
- [ ] send collection details to entrepot via [form](https://collection-guide.paperform.co/)
- [ ] top canister up with cycles
- [ ] run off chain backup script with mainnet canister id
- [ ] setup auto topup of canisters

If you want to upgrade an existing nft canister, see [upgrade nft canister](#upgrade-nft-canister)

## Create canisters
If you want to create canisters w/o using cycles wallet:
```
dfx ledger create-canister --amount 0.1 --network ic $(dfx identity get-principal)
```

## Assets

Placeholder is optional.

Extension can be any.

`assets` folder structure:
```
assets/
  metadata.json
  placeholder.svg
  1.svg
  1_thumbnail.svg
  2.svg
  2_thumbnail.svg
  ...
```

Deploy assets canister
```
dfx deploy assets --no-wallet --network ic
```

## Deploy NFT canister
For local deployment run extra commands:
```
npm run replica
npm run deploy:ledger
```

Deploy
```
npm run deploy <network>
```

`<network>` - local | test | staging | production

`local` and `test` deployed locally

`staging` and `production` deployed to IC mainnet

### Examples

Clean deploy locally
```
npm run deploy local -- --mode reinstall
```

Deploy staging
```
npm run deploy staging
```

Deploy production
```
npm run deploy production
```

## Upgrade nft canister
Upgrade production canister
```
npm run upgrade-production
```

## caveats 🕳

- The canister code is written in a way that the seed animation _ALWAYS_ has to be the first asset uploaded to the canister if you are doing a `revealDelay > 0`
- The seed animation video needs to be encoded in a way that it can be played on iOS devices, use `HandBrake` for that or `ffmpeg`

## vessel 🚢

- Run `vessel verify --version 0.8.1` to verify everything still builds correctly after adding a new depdenceny
- To use `vessels`s moc version when deploying, use `DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy`

## shuffle 🔀

- The shuffle uses the random beacon to derive a random seed for the PRNG
- It basically shuffles all the assets in the `assets` stable variable
- The linking inside the canister is

```
tokenIndex -> assetIndex
asset[assetIndex] -> NFT
```

- by shuffling the assets, we are actually changing the mapping from `tokenIndex` to `NFT`
- initially the `tokenIndex` matches the `assetIndex` (`assetIndex` = `tokenIndex+1`) and the `assetIndex` matches the `NFT` (`NFT` = `assetIndex+1`)
- but after the shuffle the `assetIndex` and the `NFT` mint number no longer match
- so so token at `tokenIndex` still points to the same asset at `assetIndex`, but this asset no longer has the same `NFT` mint number
- we can always retrieve the `NFT` mint number from the `_asset[index].name` property which we specify when adding an asset to the canister

## off-chain backup ⛓

We use the `getRegistry` (`tokenIndex -> AccountIdentifier`) and `getTokenToAssetMapping` (`tokenIndex -> NFT`) canister methods to backup state offchain. Therefore we simply use a script that queries the afore mentioned methods every 60 minutes and saves the responses on a server. You can find the script in `state_backup`. We are also submitting every transaction to `CAP`, which again offers off-chain backups of their data.

Note that the indices of the json outputs represent the indices of the internal storage. E.g. index `0` means it is the first item in the array. In the UI (entrepot or stoic wallet) those indices are incremented by one, so they start with `1` and not with `0`.

To have the same token identifiers for the same tokens, it is important to keep the order of the minting when reinstantiating the canister.

So when executing `mintNFT`, the `to` address is taken from `registry.json` and the `asset` is taken from `tokens.json`. It's important here that the uploading of the assets is on order (start with flower 1, end with flower 2009) and that the `assets` index 0 is used by something other than an NFT asset (before it was the seed animation)!

## Testing 🧪

Each test suite is deployed with its own env settings.

First, start a local replica

```
npm run replica
```

Deploy and run all unit and e2e tests

```
npm run test
```

Run only unit tests

```
npm run test:unit
```

Deploy and run specific e2e tests

```
npm run test:e2e pending-sale
```

Run tests without deployment (useful when writing tests)

```
npm run vitest
```

or

```
npm run vitest:watch
```

or run specific test suite

```
npm run vitest pending-sale
```

## Manual testing 🧪

Deploy [assets](#assets) and [NFT canister](#deploy-nft-canister).

Make sure that the NFT is redirected to the asset:

http://localhost:4943/0?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai

http://localhost:4943/1?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai

http://localhost:4943/1?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai&type=thumbnail

http://localhost:4943/?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai&type=thumbnail&asset=1

http://localhost:4943/?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai&tokenid=rrkah-fqaaa-aaaaa-aaaaq-cai should have same redirect as http://localhost:4943/0?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai


**NOTE**

you can also use `http://127.0.0.1:8000/?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai&asset=0` or `http://127.0.0.1:8000/1.svg?canisterId=rrkah-fqaaa-aaaaa-aaaaq-cai&asset=0` locally

---

add the following line to `/etc/hosts` if on mac

```
127.0.0.1       rrkah-fqaaa-aaaaa-aaaaq-cai.localhost
```

the canister can now be accesed with

```
http://rwlgt-iiaaa-aaaaa-aaaaa-cai.localhost:8453/?tokenid=rwlgt-iiaaa-aaaaa-aaaaa-cai
```

or via command line with

```
curl "rwlgt-iiaaa-aaaaa-aaaaa-cai.localhost:8453/?tokenid=rwlgt-iiaaa-aaaaa-aaaaa-cai"
```

<h2 id="ext">ext-cli 🔌</h2>

to get the tokenid from the canister and index do the following

1. clone https://github.com/Toniq-Labs/ext-cli and https://github.com/Toniq-Labs/ext-js in the same directory
2. run `npm i -g` from within `ext-cli`
3. run `ext token <canister_id> <index>`

## settlements

- if there's a settlement that didn't work, we can call the `settlements` query method and then `settle` using the index to settle the transaction

- if there a salesSettelemnts that didnt work, we call the `salesSettlements` query method and then `retrieve` using the address to settle the transaction
