# Writing an `npm start` command

## Proposal

As part of the re-architecture of the Node.js metabuildpack outlined
[here](https://github.com/paketo-buildpacks/nodejs/blob/main/rfcs/0001-buildpacks-architecture.md),
there is need for a `npm-start` buildpack with the single responsibility of
setting a start command which uses `tini` and `npm`.


## Motivation

Moving toward this single-responsibility architecture has a few advantages:

* It enables greater modularity within the Node.js language family.

* It sets the foundation for interoperability between buildpacks across
  language families.

* Using `tini` allows for more optimal process management within the container.

  `tini` is a process manager for containers which manages zombie processes and
  performs signal forwarding. Using an app start command with `tini` ensures
  that containers may be stopped gracefully once started.

## Integration

The buildpack will provide no dependencies and will require `node`, `tini`,
`npm` and `node_modules` during the launch phase.

## Implementation (Optional)

Detection will pass once a `package.json` file is present in the app's source
code, assuming all other buildplan requirements have been met.

If detection is passed, the buildpack will set a start command using `tini` and
`npm`. An example of a start command could be: `tini -g -- npm start`.
