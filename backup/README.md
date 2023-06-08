# Backup and restore canister data

## Backup
Command
```
npm run backup
```
The backup file will be saved in `data` folder.

### Possible arguments:

`--network <network>` - `ic` or `local`. *Default* `local`

`--canister-id <principal>` - canister id. *Required*

`--file <file>` - output file name. *Default* current date and time

`--chunk-size <size>` - chunk size(number of items). *Default* `5000`

Chunk size > 30k => backup fails
Chunk size > 15k => restore fails

### Example with arguments
```
npm run backup -- --network ic --canister-id rrkah-fqaaa-aaaaa-aaaaq-cai --file 2023-01-01.json --chunk-size 5000
```

# Restore
(!) If any error occurred during the restore, please follow all the steps again.

1. Add `restoreEnabled = opt true;` to `initArgs.did`
2. Reinstall canister with clear all data
```
dfx deploy <canister> --network <network> --mode reinstall
```
3. Perform restore
### Possible arguments:

`--network <network>` - `ic` or `local`. *Default* `local`

`--canister-id <principal>` - canister id. *Required*

`--file <file>` - file name within `./backup/data` to restore. *Required*

`--pem <pem_data>` - PEM-file data. *Required*

```
npm run restore -- --network <network> --file <backup-file> --pem "$(dfx identity export <identity_name>)"
```

Example:
```
npm run restore -- --network ic --canister-id rrkah-fqaaa-aaaaa-aaaaq-cai --file 2023-01-01.json --pem "$(dfx identity export default)"
```

4. Remove `restoreEnabled = opt true;` from `initArgs.did`
4. Upgrade canister
```
dfx deploy <canister> --network <network>
```
