import {AccountIdentifier} from '@dfinity/nns';
import {describe, test, expect, it} from 'vitest';
import {ICP_FEE} from './consts';
import {applyFees, buyFromSale, checkTokenCount, tokenIdentifier} from './utils';
import {whitelistTier0, whitelistTier1} from './well-known-users';
import env from './marketplace/env';

console.log(env)
console.log(describe)
console.log(expect)
console.log(it)
console.log(ICP_FEE)
console.log(buyFromSale)
import {User} from './user';
let user = new User();
let minter = new User('minter');

(async () => {
  console.log(await user.icpActor.account_balance({account: user.account}));
  console.log(await user.mainActor.reserve(user.accountId));
  console.log(await user.icpActor.transfer_fee({account: user.account}));
  console.log(await minter.icpActor.transfer({
    from_subaccount: [],
    to: user.account,
    amount: {e8s: 10_000n},
    fee: {e8s: 0n},
    memo: 0n,
    created_at_time: [],
  }));
  console.log(await minter.icpActor.transfer({
    from_subaccount: [],
    to: user.account,
    amount: {e8s: 10_000n},
    fee: {e8s: 0n},
    memo: 0n,
    created_at_time: [],
  }));
  await user.mintICP(10_000n);
  console.log(await user.icpActor.account_balance({account: user.account}));
  console.log(fetch);
  user = new User();
  console.log(await user.icpActor.account_balance({account: user.account}));


  let res = await user.mainActor.list({
    price: [BigInt(1000)],
    token: new User().accountId,
    from_subaccount: [],
    frontendIdentifier: [],
  });
})();