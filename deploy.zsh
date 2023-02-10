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
dfx deploy --network $network --argument "(principal \"$ID\")" $mode
else
echo "staging deployment ..."
dfx canister --network $network create $mode
ID=$(dfx canister --network $network id $mode)
yes yes| dfx deploy --network $network --argument "(principal \"$ID\")" --mode=reinstall $mode
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
		echo "https://$(dfx canister --network $network id $mode).raw.ic0.app/?tokenid=$tokenid"
done

# now shuffle the assets using the random beacon
# echo "shuffling assets"
# dfx canister --network $network call staging shuffleAssets

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