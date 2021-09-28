# Volume Mount Buildpack

## Summary

Implement a new buildpack that can inject volume-mounted files into the application directory.

## Motivation

Sometimes users have pieces of their application that, for one reason or another, they do not want to commit into their source code repository ([example](https://github.com/paketo-buildpacks/nginx/issues/281)).

## Detailed Explanation

Implementing this RFC would amount to creating a new repo within the Paketo Buildpacks GitHub organization to house the buildpack. The buildpack would then be eventually added to all groups (as **optional**) within Paketo builders to make it available for use.

A user could then use the buildpack by supplying a volume mount during a build (e.g. `--volume` flag in `pack`, or a k8s volume mount). The user could then expect the contents of the volume to be copied into the application directory during the build phase of the proposed buildpack.

For example, if a user has an application directory of the following structure:

```
<app-dir>
├── package.json
├── node_modules
│   ├── ...
```

and they supplied a volume mount of the following structure:

```
/my-volume
├── some-dir
│   ├── sub-dir
│   │   ├── some-file
├── other-file
```

they could expect that their app directory would contain the following after the buildpack executes:

```
<app-dir>
├── package.json
├── node_modules
│   ├── ...
├── some-dir
│   ├── sub-dir
│   │   ├── some-file
├── other-file
```

Note:
- `my-volume` itself was not copied, just its contents.
- If any file collisions occur, the volume-mounted files would take precedence.

## Rationale and Alternatives

We could leverage the [service binding spec](https://github.com/servicebinding/spec#workload-projection) was considered, especially since this is [now implemented in packit](https://github.com/paketo-buildpacks/packit/pull/228), and update buildpacks on a case-by-case basis (such as updating the nginx buildpack to search for a `nginx.conf` binding), but this would amount to individual buildpack complexity when a modular and more generic approach is available.

## Implementation

Related to the mention of service bindings above, we could also consider using service bindings for the implementation of the proposed buildpack, especially since `packit` supports resolving bindings already. However, there are some drawbacks to this:

- Service bindings are not intended to become content of the built image, simply data to support integration of external services.

- Service bindings happen to use volume mounts as an implementation detail, and therefore have strict requirements as to the folder structure within a binding. It would NOT allow generic folder structures to be injected into the application directory because of this.

Instead, a custom utility buildpack could operate on environment variables:

- `$BP_VOLUME_MOUNT_SOURCE`: specifies the source location of the volume, as an absolute path.

- `$BP_VOLUME_MOUNT_DEST`: specifies the target directory -- relative to the application directory -- into which the volume contents will be copied.

  - Refers to a directory, not a file.
  
  - If any intermediate directories do not already exist within the application directory, they will be created (e.g. setting `$BP_VOLUME_MOUNT_DEST=foo/bar` will create `<app-dir>/foo/bar` then copy contents into `bar`).

  - An empty or `.` value implies the application directory itself.

  - Anything outside the app dir, including absolute paths, would be disallowed (i.e. anything beginning with `../` or `/`).

### Detect

Detection will pass if `$BP_VOLUME_MOUNT_SOURCE` is set. Otherwise, detection will fail.

### Build

During build, the glob `$BP_VOLUME_MOUNT_SOURCE/**` will be recursively copied to `$BP_VOLUME_MOUNT_DEST`.

## Unresolved Questions and Bikeshedding

- Should `$BP_VOLUME_MOUNT_SOURCE` have a default?

- Should detection be based on the presence of the volume rather than the environment variable? (Note, would require `$BP_VOLUME_MOUNT_SOURCE` to have a default).

- Detection: What if a later buildpack relies on a file that will be volume mounted? It wouldn't be available during detection as the build phase would not have executed yet.
