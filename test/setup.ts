import path from 'path';
import {execSync} from 'child_process';
import {beforeAll} from 'vitest';
import {applyEnv} from './apply-env';

let prevEnvName = '';

beforeAll((suite) => {
  let envName = path.dirname(suite.name).split('/').at(-1);
  if (envName !== prevEnvName) {
    applyEnv(envName);
    execSync(`npm run deploy-test`);

    if (envName === 'multi-asset') {
      execSync(`npm run mint:test-2`);
    }
    else if (envName === 'single-asset-delayed-reveal') {
      execSync(`npm run mint:test-2`);
      execSync(`dfx canister call test shuffleTokensForSale`);
    }
    else {
      execSync(`npm run mint:test`);
    }
  }
  prevEnvName = envName;
});