# Reimplement NPM Start Command

## Proposal

The buildpack will no longer call `npm start` directly, but instead will
reimplement the behavior of `npm start` directly.

## Motivation

We've seen flakey issues with process signal handling once we implemented [RFC
0001](0001-start-command.md). Specifically, on some container managers, it
appears that `tini` is not waiting for the entire process group to exit before
exiting itself. This means that our tests that make assertions that log lines
appear in the output during process shutdown are unreliable.

Furthermore, the maintainers of the `npm` CLI have [openly
stated](https://github.com/npm/npm/issues/4603#issuecomment-170175517) that
they do not view `npm start` as a production-ready solution for running
applications.

Given all of this, it seems to make more sense now to just take on the cost of
reimplementing the behavior of `npm start` and removing the complexity of using
`npm` and `tini` together.

## Implementation

The buildpack will still require `node` and `node_modules` during the `launch`
phase, but will no longer need to require `npm` or `tini`.

Detection will continue to pass once a `package.json` file is present in the
app's source code, assuming all other buildplan requirements have been met.

If detection is passed, the buildpack will set a start command, optionally also
running the prestart and poststart commands using using the contents of the
`package.json` as follows:

* If `package.json` contains `scripts.start`, `scripts.prestart`, and `scripts.poststart` fields, the
  start command will be `<prestart command> && <start command> && <poststart command>`. For example,
  given the following `package.json`,

  ```json
  {
    "scripts": {
      "poststart": "echo 'Done starting'",
      "prestart": "echo 'Starting'",
      "start": "node index.js"
    }
  }
  ```

  The start command will be `echo 'Starting' && node index.js && echo 'Done starting'`.

* If `package.json` contains `scripts.start` and `scripts.prestart` fields, but
  does not contain a `scripts.poststart` field, the start command will be
  `<prestart command> && <start command>`. For example, given the following
  `package.json`,

  ```json
  {
    "scripts": {
      "prestart": "echo 'Starting'",
      "start": "node index.js"
    }
  }
  ```

  The start command will be `echo 'Starting' && node index.js`.

* If `package.json` contains `scripts.start` and `scripts.poststart` fields,
  but does not contain a `scripts.prestart` field, the start command will be
  `<start command> && <poststart command>`. For example, given the following
  `package.json`,

  ```json
  {
    "scripts": {
      "poststart": "echo 'Done starting'",
      "start": "node index.js"
    }
  }
  ```

  The start command will be `node index.js && echo 'Done starting'`.

* If `package.json` contains a `scripts.start`, but does not contain either a
  `scripts.prestart` or `scripts.poststart` field, the start command will be
  `<start command>`. For example, given the following `package.json`,

  ```json
  {
    "scripts": {
      "start": "node index.js"
    }
  }
  ```

  The start command will be `node index.js`.

* If `package.json` does not contain `scripts.start`, `scripts.prestart`, or
  `scripts.poststart` fields, the start command will be `node server.js`. For
  example, given the following `package.json`,

  ```json
  {}
  ```

  The start command will be `node server.js`.
