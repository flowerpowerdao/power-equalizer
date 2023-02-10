let { execSync } = require("child_process");

let reinstallEach = false;
let growSize = 20_000;

let canisters = [
  "copying-force",
  "compacting-force",
  "generational-force",
  // 'copying',
  // 'compacting',
  // 'generational',
];

let transactionSizes = [
  40_000, 100_000, 400_000, 800_000, 1_000_000, 1_400_000, 2_000_000, 2_800_000,
  3_400_000, 4_000_000, 5_000_000,
];

let grow = (canister, n) => {
  let res = execSync(`dfx canister call ${canister} grow ${n}`);
  // console.log(res.toString().trim());
};

let getHeapSize = (canister) => {
  try {
    let res = execSync(`dfx canister call ${canister} getHeapSize`);
    return formatMemorySize(
      parseInt(res.toString().trim().match(/\d/g).join(""))
    );
  } catch (e) {
    console.error(e.message);
    return "err";
  }
};

let getMaxLiveSize = (canister) => {
  try {
    let res = execSync(`dfx canister call ${canister} getMaxLiveSize`);
    return formatMemorySize(
      parseInt(res.toString().trim().match(/\d/g).join(""))
    );
  } catch (e) {
    console.error(e.message);
    return "err";
  }
};

let getMemorySize = (canister) => {
  try {
    let res = execSync(`dfx canister call ${canister} getMemorySize`);
    return formatMemorySize(
      parseInt(res.toString().trim().match(/\d/g).join(""))
    );
  } catch (e) {
    console.error(e.message);
    return "err";
  }
};

let formatMemorySize = (size) => {
  return (size / 1024 / 1024).toFixed(2);
};

let upgrade = (canister) => {
  try {
    execSync(
      `dfx deploy ${canister} --upgrade-unchanged --argument '(principal "'$(dfx canister id ${canister})'")'`,
      { stdio: "pipe" }
    );
  } catch (e) {
    console.error(e.message);
    return false;
  }
  return true;
};

let reinstall = (canister) => {
  execSync(
    `dfx deploy ${canister} --mode reinstall -y --argument '(principal "'$(dfx canister id ${canister})'")'`,
    { stdio: "pipe" }
  );
};

let currTransactions = 0;
let logs = [];

loop: for (let canister of canisters) {
  execSync(`dfx canister create ${canister}`);

  for (size of transactionSizes) {
    try {
      console.log("-".repeat(50));

      if (reinstallEach || size === transactionSizes[0]) {
        console.log("Reinstalling...");
        reinstall(canister);
        console.log("Reinstalled");
        currTransactions = 0;
      }

      console.log(`Growing transaction size to ${size.toLocaleString()}...`);
      let iterCount = (size - currTransactions) / growSize;
      for (i = 0; i < iterCount; i++) {
        currTransactions += growSize;
        grow(canister, growSize);
      }

      let log = {
        gc: canister,
        transactions: currTransactions.toLocaleString(),
        reinstall: reinstallEach,
        "max live": `${getMaxLiveSize(canister)} MB`,
        "heap": `${getHeapSize(canister)} MB`,
        memory: `${getMemorySize(canister)} MB`,
      };

      console.log("Upgrading...");
      let upgraded = upgrade(canister);

      // grow(canister, 10);

      log["upgrade successful"] = upgraded;
      log["max live postupgrade"] = `${getMaxLiveSize(canister)} MB`;
      log["heap postupgrade"] = `${getHeapSize(canister)} MB`;
      log["memory postupgrade"] = `${getMemorySize(canister)} MB`;

      logs.push(log);
      console.table(logs);

      if (!upgraded) {
        continue loop;
      }
    } catch (err) {
      console.log("unexpected error", err);
      continue loop;
    }
  }
}

console.log("done");
