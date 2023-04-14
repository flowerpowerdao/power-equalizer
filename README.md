![BP_FPDAO_Logo_BlackOnWhite_sRGB_2](https://user-images.githubusercontent.com/32162112/221128811-5484d430-c357-49e8-8b25-0f04695a5691.svg)

# power equalizer 🌼

## pre launch

- [ ] adapt `initArgs.did` to your needs
- [ ] add canister to [DAB](https://docs.google.com/forms/d/e/1FAIpQLSc-0BL9FMRtI0HhWj4g7CCYjf3TMr4_K_qqmagjzkUH_CKczw/viewform)
- [ ] send collection details to entrepot via form
- [ ] top canister up with cycles
- [ ] run off chain backup script with mainnet canister id
- [ ] setup auto topup of canisters

## launch

- run `make deploy-production-ic-full`
- check if all assets uploaded correctly by calling the canisters `getTokenToAssetMapping()` method

## deploy 📚

We are using a makefile to simplify the deployment of canisters for different scenarios.

```
# makefile
deploy-locally:
	./deploy.zsh

deploy-staging-ic:
	./deploy.zsh ic

deploy-staging-ic-full:
	./deploy.zsh ic 7777

deploy-production-ic-full:
	./deploy.zsh ic 7777 production
```

This `makefile` calls the `deploy.zsh` script.

```
# deploy.zsh
#!/bin/zsh
# stream asset to the canister using this
# https://gist.github.com/jorgenbuilder/6d32ef665b84457a9be2063224b754fb
file="assets/output.mp4"
filename=$(echo $file | sed -E "s/.+\///")
fileextension=$(echo $file | sed -E "s/.+\.//")
mime="video/$fileextension"
network=${1:-local}
number_of_assets=${2:-10}
mode=${3:-staging}
threshold="100000"
asset_canister_url="https://zt63f-rqaaa-aaaae-qadaq-cai.raw.ic0.app/"

dfx stop
dfx start --background --clean

# reset the canister state
if [[ "$mode" == "production" ]]
then
echo "production deployment ..."
dfx canister --network $network create $mode
ID=$(dfx canister --network $network id $mode)
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy --network $network --argument "(principal \"$ID\")" $mode
else
echo "staging deployment ..."
dfx canister --network $network create $mode
ID=$(dfx canister --network $network id $mode)
yes yes| DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy --network $network --argument "(principal \"$ID\")" --mode=reinstall $mode
fi


# first create the asset calling addAsset
echo "creating asset..."
asset_id=$(dfx canister --network $network call $mode addAsset "(record { \
    name = \"$filename\"; \
    payload = record {
        ctype = \"$mime\"; \
        data = vec {\
}}})")

asset_id=$(echo $asset_id | tr -d -c 0-9)
echo $asset_id

# then chunk the file and upload it to the asset
# id using streamAsset
i=0
byteSize=${#$(od -An -v -tuC $file)[@]}
echo "$network Uploading asset \"$filename\", size: $byteSize"
while [ $i -le $byteSize ]; do
    echo "chunk #$(($i/$threshold+1))..."
    dfx canister --network $network call $mode streamAsset "($asset_id, \
        false, \
        vec { $(for byte in ${(j:;:)$(od -An -v -tuC $file)[@]:$i:$threshold}; echo "$byte;") }\
    )"
    # dfx canister call staging addAsset "( vec {\
    #     vec { $(for byte in ${(j:;:)$(od -An -v -tuC $file)[@]:$i:$threshold}; echo "$byte;") };\
    # })"
    i=$(($i+$threshold))
done

if [[ "$network" == "ic" ]]
then
open "https://$(dfx canister --network $network id $mode).raw.ic0.app/?asset=0"
else
open "http://127.0.0.1:4943/?canisterId=$(dfx canister --network $network id $mode)&asset=0"
fi

# add the other assets
upload_assets() {
    for asset in {$k..$(($k+$batch_size-1))}; do
        if [ $asset -gt $number_of_assets ];
            then break;
        fi;
        j=$asset-1;
        dfx canister --network $network call --async $mode addAsset '(record {
            name = "'$asset'";
            payload = record {
                ctype = "image/svg+xml";
                data = vec {blob "
                    <svg xmlns=\"http://www.w3.org/2000/svg\">
                        <script>
                            fetch(\"'$asset_canister_url$asset'.svg\")
                            .then(response =&gt; response.text())
                            .then(text =&gt; {
                                let parser = new DOMParser();
                                let doc = parser.parseFromString( text, \"image/svg+xml\" );
                                document.getElementsByTagName(\"svg\")[0].appendChild( doc.getElementsByTagName(\"svg\")[0] );
                            })
                            .catch(err =&gt; console.log(err))
                        </script>
                    </svg>"
                };
            };
            thumbnail = opt record {
                ctype = "image/svg+xml";
                data = vec {blob "
                    <svg xmlns=\"http://www.w3.org/2000/svg\">
                        <script>
                            fetch(\"'$asset_canister_url$asset'_thumbnail.svg\")
                            .then(response =&gt; response.text())
                            .then(text =&gt; {
                                let parser = new DOMParser();
                                let doc = parser.parseFromString( text, \"image/svg+xml\" );
                                document.getElementsByTagName(\"svg\")[0].appendChild( doc.getElementsByTagName(\"svg\")[0] );
                            })
                            .catch(err =&gt; console.log(err))
                        </script>
                    </svg>"
                };
            };
            metadata = opt record {
                ctype = "application/json";
                data = vec {blob "'"$(cat assets/metadata.json | jq ".[$j]" | sed 's/"/\\"/g')"'"
                };
            };
        })' &>/dev/null
    done
}

batch_size=1000
k=1
while [ $k -le $number_of_assets ]; do
    upload_assets &
    k=$(($k+$batch_size))
done
jobs
wait
echo "done"

# init cap
echo "initiating cap ..."
dfx canister --network $network call $mode initCap

# init mint
echo "initiating mint ..."
dfx canister --network $network call $mode initMint

# shuffle Tokens For Sale
echo "shuffle Tokens For Sale ..."
dfx canister --network $network call $mode shuffleTokensForSale

# airdrop tokens
echo "airdrop tokens ..."
dfx canister --network $network call $mode airdropTokens 0

# airdrop tokens
echo "airdrop tokens ..."
dfx canister --network $network call $mode airdropTokens 1500

# enable sale
echo "enable sale ..."
dfx canister --network $network call $mode enableSale

# check the asset that are linked to the tokens
for i in {0..9}
do
    tokenid=$(ext tokenid $(dfx canister --network $network id $mode) $i | sed -n  2p)
		tokenid=$(echo $tokenid | tr -dc '[:alnum:]-')
		tokenid="${tokenid:3:-2}"
    if [[ "$network" == "ic" ]]
    then
      echo "https://$(dfx canister --network $network id $mode).raw.ic0.app/?tokenid=$tokenid"
    else
      echo "http://127.0.0.1:4943/?canisterId=$(dfx canister --network $network id $mode)&tokenid=$tokenid"
    fi
done

# after assets are shuffled and revealed
# check the assets again to see if we now indeed
# see the correct assets
# for i in {0..9}
# do
#         tokenid=$(ext tokenid $(dfx canister --network ic id staging) $i | sed -n  2p)
# 		tokenid=$(echo $tokenid | tr -dc '[:alnum:]-')
# 		tokenid="${tokenid:3:-2}"
# 		curl "$(dfx canister --network ic id staging).raw.ic0.app/?tokenid=$tokenid"
# 		echo "\n"
# done
```

Because the `makefile` and `deploy.zsh` are pretty opinated, we are not including them in the repo. You can use node or python scripts to deploy the canisters and upload the assets, make sure you mimic the functinoality of the `makefile` and `deploy.zsh` scripts. The following bulletpoints are tips and tricks if you stick to our way of uploading assets.

- use `make` to run the standard local deploy
- use `make deploy-staging-ic` to deploy the staging canister to the mainnet, by default it deploys the NFT staging canister locally and uses `assets/output.mp4` and `metadata.json` as file paths
  - `metadata.json` **MUST NOT** contain a mint number! (use `cat mymetadata.json| sed '/mint/ d' > metadata.json` to remove the mint number)
  - note that you need [ext](#ext) installed
- The `deploy.zsh` adds another oracle to the NFT canister because the script in the source SVG won't be executed the way it's currently structured. Make sure you use the correct API endpoint there as well!
  - note: this script is not allowed to contain any `&` or `>` characters!
  - make sure you change the asset canister url and the currency fetched from the oracle
- make sure you create and `assets` folder and provide the `seed.mp4` file and the `metadata.json` file and specify their names in the script accordingly
- the weird looking `sed` when uploading the metadata is escaping `"` characters and the variable `$j` is needed for the correct index (`j=$i-1`)

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

First, start a local replica and deploy

```
npm run replica
npm run deploy
```

To deploy and run all tests

```
npm run test
```

To deploy and run specific tests

```
npm run test pending-sale
```

To run tests without deployment (useful when writing tests)

```
npm run vitest
```

or

```
npm run vitest:watch
```

or to run specific test suite

```
npm run vitest pending-sale
```

## manual testing 🧪

deploy the canister with

```
dfx deploy
```

use the following command to upload an asset that fits into a single message

```
dfx canister call btcflower addAsset '(record {name = "privat";payload = record {ctype = "text/html"; data = vec {blob "hello world!"} } })'
```

use the following command to mint a token

```
dfx canister call btcflower mintNFT '(record {to = "75c52c5ee26d10c7c3da77ec7bc2b4c75e1fdc2b92e01d3da6986ba67cfa1703"; asset = 0 : nat32})'
```

run icx-proxy to be able to user query parameters locally

```
$(dfx cache show)/icx-proxy --address 127.0.0.1:8453 -vv
```

---

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
