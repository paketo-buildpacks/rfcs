# Reloadable Process Types

## Summary

Provide a utility buildpack to support language buildpacks in creating reloadable process types for their run containers.

## Motivation

Usage of dev orchestration tools like Tilt and Skaffold are on the rise. These tools aim to make developing distributed software that runs on Kubernetes easier.  Offering the capability to develop inside the container via live reload features.  With this, changes are streamed from the developer’s workstation into the running container whereupon the init process is restarted.  The dev orchestrator, of course, handles most of this by building the changes and copying them in the container but ultimately the running container needs the ability to restart its entrypoint process for the changes to take effect.

Today buildpacks are unable to participate in these live reload development workflows but, moving forward, we would very much like them to be able to.

## Detailed Explanation

We propose creating a utility buildpack that packages the watchexec command line utility for restarting arbitrary processes.  The intention is that this buildpack would add the watchexec binary only.

When enabled by a BP_LIVE_RELOAD_ENABLED=true environment variable, the language buildpacks may then opt-in to using this watchexec binary to create a reloadable process type.

This affords language buildpacks the ability to support the reloadable process requirements imposed by modern dev orchestrators by providing the ability to always create a reloadable process type even when no native language-support exists.  For example, the java buildpack may well prefer to use spring-boot-devtools, if available, but can always fallback to watchexec otherwise producing a reloadable process type:

`watchexec -r java org.springframework.boot.loader.JarLauncher`

This makes watchexec the stable init process in the run container that monitors the workspace directory for file changes, restarting the app process when they occur.

### Language-support

We would like to propose support for Java first, extending to other languages as priority dictates.

An example of how this might be used by Tilt for a Java application is as follows:

```
    custom_build('localhost:5000/apps/fooservice', 
      'pack build -e BP_LIVE_RELOAD_ENABLED=true --tag $EXPECTED_REF --publish,
      ['pom.xml'],
      live_update = [
        sync('./target/classes', '/workspace/BOOT-INF/classes')
      ]
    )
    k8s_yaml('k8s/deployment.yaml'))
    k8s_resource('fooservice', port_forwards="8080:8080”)
```

With this Tiltfile when `tilt up` is run it will perform an initial image build, using pack, and deployment of the spring-petclinic app defined in `k8s/deployment.yaml`.  Note, that pack publishes an image using the tag Tilt's wants it's custom build to use.  Tilt then live sync's a limited set of changes directly into the application container.  In this case, changes within the existing Java classpath that are compiled by the IDE.  The monitoring watchexec process, seeing these changes, then restarts the application process.  Other changes outside of this, to the `pom.xml` for example, trigger a full rebuild and redeployment again delegating to pack to do so.

### Notes

Note that watchexec watches the current directory (and below). The working directory is the app directory so all buildpacks wishing to support reloadable process types would need to contribute their entrypoint processes to the app directory.

Note also that watchexec supports shell-less invocation and therefore will be able to support the tiny builder that produces a run image with no shell.  

It also supports windows through both Cmd and Powershell shells. 

## Rationale and Alternatives

In terms of the restart utility we did initially consider [entr](http://eradman.com/entrproject/) but as can be seen from the documentation it relies on bash and that, of course, won't work with the paketo tiny stack. 
