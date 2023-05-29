import path from 'path';
import {execSync} from 'child_process';
import {beforeAll} from 'vitest';
import {applyEnv} from './apply-env';

beforeAll(async (suite) => {
  let envName = path.dirname(suite.name).split('/').at(-1);

  if (envName !== globalThis.prevEnvName) {
    globalThis.prevEnvName = envName;

    await applyEnv(envName);

    execSync(`npm run deploy-test`, {
      cwd: path.resolve(__dirname, '..'),
      stdio: ['ignore', 'ignore', 'pipe'],
    });

    if (envName === 'multi-asset') {
      execSync(`npm run mint:test-2`);
    }
    else if (envName === 'single-asset-delayed-reveal') {
      execSync(`npm run mint:test-2`);
      execSync(`dfx canister call test shuffleTokensForSale`);
    }
    else if (envName !== 'backup-assets') {
      execSync(`npm run mint:test`);
    }
  }
});