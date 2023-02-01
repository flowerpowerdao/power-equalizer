let {execSync} = require('child_process');

let grow = (canister, n) => {
  execSync(`dfx canister call ${canister} grow ${n}`);
}

let getHeapSize = (canister) => {
  let res = execSync(`dfx canister call ${canister} getHeapSize`);
  return parseInt(res.toString().trim().match(/\d/g).join(''))
}

let getMemorySize = (canister) => {
  let res = execSync(`dfx canister call ${canister} getMemorySize`);
  return parseInt(res.toString().trim().match(/\d/g).join(''))
}

let upgrade = (canister) => {
  try {
    execSync(`dfx deploy ${canister} --upgrade-unchanged --argument '(principal "'$(dfx canister id ${canister})'")'`, {stdio: 'pipe'});
  } catch (e) {
    console.error(e.message);
    return false;
  }
  return true;
}

let reinstall = (canister) => {
  execSync(`dfx deploy ${canister} --mode reinstall -y --argument '(principal "'$(dfx canister id ${canister})'")'`, {stdio: 'pipe'});
}

let canisters = [
  'force-gc-copying-gc',
  'force-gc-compacting-gc',
  'copying-gc',
  'compacting-gc',
];

let transactionSizes = [
  20_000,
  60_000,
  100_000,
  200_000,
  400_000,
  800_000,
  1_000_000,
  1_400_000,
  2_000_000,
  2_800_000,
  4_000_000,
];
let growSize = 20_000;

let logs = [];

loop: for (let canister of canisters) {
  execSync(`dfx canister create ${canister}`);

  for (size of transactionSizes) {
    console.log('-'.repeat(50));

    console.log('Reinstalling...');
    reinstall(canister);
    console.log('Reinstalled');

    console.log(`Growing transaction size to ${size}...`);
    for (i = 0; i < size / growSize; i++) {
      grow(canister, growSize);
    }

    let log = {
      'canister': canister,
      'memory size before upgrade': `${(getMemorySize(canister) / 1024 / 1024).toFixed(2)} MB`,
      // 'heap size before upgrade': `${getHeapSize() / 1024 / 1024} MB`,
    };

    console.log('Upgrading...');
    let upgraded = upgrade(canister);

    log['memory size after upgrade'] = `${(getMemorySize(canister) / 1024 / 1024).toFixed(2)} MB`;
    // log['heap size before upgrade'] = `${getHeapSize() / 1024 / 1024} MB`;
    log['upgrade successful'] = upgraded;

    logs.push(log);
    console.table(logs);

    if (!upgraded) {
      continue loop;
    }
  }
}

console.log('done');