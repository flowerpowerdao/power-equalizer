import { User } from './user';

export let whitelistTier0 = Array(100).fill(0).map((_, i) => {
   return new User(`whitelist-tier-0-${i}`);
});

export let whitelistTier1 = Array(100).fill(0).map((_, i) => {
   return new User(`whitelist-tier-1-${i}`);
});

export let airdrop = Array(100).fill(0).map((_, i) => {
   return new User(`airdrop-${i}`);
});