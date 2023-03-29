#!/usr/bin/env bash
set -e
cat <<<"$(jq '.canisters.ledger.candid="./declarations/ledger/ledger.private.did"' dfx.json)" >dfx.json
npm run deploy:ledger-wasm
cat <<<"$(jq '.canisters.ledger.candid="./declarations/ledger/ledger.public.did"' dfx.json)" >dfx.json