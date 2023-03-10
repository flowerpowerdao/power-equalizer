# Backup and restore canister data

## Backup
Command
```
npm run backup
```
The backup file will be saved in `data` folder.

### Possible arguments:

`--network <network>` - `ic` or `local`. *Default* `local`

`--file <file>` - output file name. *Default* current date and time

`--chunk-size <size>` - chunk size(number of items). *Default* `10000`

### Example with arguments
```
npm run backup -- --network ic --file 2023-01-01.json --chunk-size 5000
```

# Restore
(!) If any error occurred during the restore, please follow all the steps again.

1. Change in `Env/lib.mo`
```diff
-public let restoreEnabled = false;
+public let restoreEnabled = true;
```
2. Reinstall canister with clear all data
```
dfx deploy <canister> --network <network> --mode reinstall
```
3. Perform restore
```
npm run restore -- --network <network> --file <backup-file>
```