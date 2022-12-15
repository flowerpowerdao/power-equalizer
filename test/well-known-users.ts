import { User } from './user';

export let ethFlowerWhitelist = Array(100).fill(0).map((_, i) => {
   new User(`ethFlowerWhitelist-${i}`)
});

export let modclubWhitelist = Array(100).fill(0).map((_, i) => {
   new User(`modclubWhitelist-${i}`)
});

export let airdrop = Array(100).fill(0).map((_, i) => {
   new User(`airdrop-${i}`)
});