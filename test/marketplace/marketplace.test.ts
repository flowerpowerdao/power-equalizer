import { describe, test, expect, it } from 'vitest';
import { User } from '../user';
import { buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.marketplace';

import canisterIds from '../../.dfx/local/canister_ids.json';

describe('marketplace', () => {
  test('try to list someone else\'s nft', async () => {
    let user = new User;

    // list
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [1000_000n],
      token: tokenIdentifier(canisterIds.staging.local, 123),
    });

    expect(res).toHaveProperty('err');
  });
});