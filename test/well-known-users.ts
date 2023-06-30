import { User } from './user';

export let beneficiaries = Array(10).fill(0).map((_, i) => {
  return new User(`beneficiary-${i}`);
});

// addresses that are in both whitelist tiers and in airdrop
export let lucky = Array(10).fill(0).map((_, i) => {
  return new User(`lucky-${i}`);
});

export let doubleSpot = Array(10).fill(0).map((_, i) => {
  return new User(`double-spot-${i}`);
});

export let whitelistTier0 = [...Array(10).fill(0).map((_, i) => {
  return new User(`whitelist-tier-0-${i}`);
}), ...lucky, ...doubleSpot, ...doubleSpot];

export let whitelistTier1 = [...Array(10).fill(0).map((_, i) => {
  return new User(`whitelist-tier-1-${i}`);
}), ...lucky, ...doubleSpot, ...doubleSpot];

export let airdrop = [...Array(10).fill(0).map((_, i) => {
  return new User(`airdrop-${i}`);
}), ...lucky];