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
  }
  prevEnvName = envName;
});