# Configuration
Collection canister is configured via `initArgs.did` file.

Customize `initArgs.did` before you deploy the canister.

## Additional settings

### Airdrop
```candid
airdrop = vec { "<address1>"; "<address2>"... };
```

## Settings with default values
Default values are used for the following settings if they are not specified in `initArgs.did` or equal to `null`

```candid
escrowDelay = opt variant { minutes = 2 }; // How much time does the user have to transfer ICP
marketDelay = opt variant { days = 2 }; // How long to delay market opening (2 days after public sale started or when sold out)
timersInterval = opt variant { seconds = 60 }; // Interval for sending deferred payments
```
