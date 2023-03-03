let { execSync, spawn } = require("child_process");
const { performance } = require("perf_hooks");

let reinstallEach = false;
let growSize = 1_000;
let concurrentCalls = 10;

let canisters = [
  "copying",
  "compacting",
  "generational",
  "copying-force",
  "compacting-force",
  "generational-force",
];

let transactionSizes = [
  400_000, 800_000, 1_000_000, 1_400_000, 2_000_000, 2_800_000, 3_400_000,
  4_000_000, 5_000_000,
];

let grow = (canister, n) => {
  return `dfx canister call ${canister} grow ${n}`;
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
      `DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy ${canister} --upgrade-unchanged --argument '(principal "'$(dfx canister id ${canister})'")'`,
      { stdio: "pipe" }
    );
  } catch (e) {
    console.error(e.message);
    return false;
  }
  return true;
};

let stop = (canister) => {
  try {
    execSync(`DFX_MOC_PATH="$(vessel bin)/moc" dfx canister stop ${canister}`, {
      stdio: "pipe",
    });
  } catch (e) {
    console.error(e.message);
    return false;
  }
  return true;
};

let start = (canister) => {
  try {
    execSync(
      `DFX_MOC_PATH="$(vessel bin)/moc" dfx canister start ${canister}`,
      {
        stdio: "pipe",
      }
    );
  } catch (e) {
    console.error(e.message);
    return false;
  }
  return true;
};

let reinstall = (canister) => {
  execSync(
    `DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy ${canister} --mode reinstall -y --argument '(principal "'$(dfx canister id ${canister})'")'`,
    { stdio: "pipe" }
  );
};

let fabricateCycles = (canister) => {
  execSync(
    `DFX_MOC_PATH="$(vessel bin)/moc" dfx ledger fabricate-cycles --canister ${canister} --amount 10000`,
    { stdio: "pipe" }
  );
};

let currTransactions = 0;
let logs = [];

async function main() {
  loop: for (let canister of canisters) {
    execSync(`dfx canister create ${canister}`);

    for (size of transactionSizes) {
      try {
        console.log("-".repeat(50));

        if (reinstallEach || size === transactionSizes[0]) {
          console.log("Reinstalling...");
          reinstall(canister);
          console.log("Reinstalled");
          console.log("Fabricating cycles...");
          fabricateCycles(canister);
          console.log("Fabricated cycles");
          currTransactions = 0;
        }

        console.log(`Growing transaction size to ${size.toLocaleString()}...`);
        const totalStart = performance.now();
        let iterCount = (size - currTransactions) / growSize / concurrentCalls;
        for (i = 0; i < iterCount; i++) {
          currTransactions += growSize * concurrentCalls;
          // Create 50 shell commands
          const commands = Array.from({ length: concurrentCalls }, () =>
            grow(canister, growSize)
          );

          const promises = commands.map((command) => {
            return new Promise((resolve, reject) => {
              const child = spawn(command, { shell: true });

              child.stdout.on("data", (data) => {
                // console.log(`stdout: ${data}`);
              });

              child.stderr.on("data", (data) => {
                console.error(`stderr: ${data}`);
                reject(`stderr: ${data}`);
              });

              child.on("error", (error) => {
                reject(error);
              });

              child.on("close", (code) => {
                if (code === 0) {
                  resolve();
                } else {
                  reject(`Command failed with code ${code}`);
                }
              });
            });
          });

          console.log(`Growing transactions to ${currTransactions}/${size}`);

          // Execute all commands in parallel
          const start = performance.now();

          await Promise.all(promises).then(() => {
            console.log("All commands executed successfully");
          });
          const end = performance.now();
          const elapsed = (end - start) / 1000;

          console.log(`Took ${elapsed} seconds to execute`);
        }
        const totalEnd = performance.now();
        const elapsed = (totalEnd - totalStart) / 1000;

        console.log(`Took ${elapsed} seconds to execute`);

        let log = {
          gc: canister,
          transactions: currTransactions.toLocaleString(),
          reinstall: reinstallEach,
          "max live": `${getMaxLiveSize(canister)} MB`,
          heap: `${getHeapSize(canister)} MB`,
          memory: `${getMemorySize(canister)} MB`,
        };

        console.log("Stopping...");
        stop(canister);
        console.log("Upgrading...");
        let upgraded = upgrade(canister);
        console.log("Starting...");
        start(canister);

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
}

main();
