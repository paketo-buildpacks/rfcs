# Reloadable Process Types

## Summary

Provide a utility buildpack to support language buildpacks in creating reloadable process types for their run containers.

## Motivation

Usage of dev orchestration tools like Tilt and Skaffold are on the rise. These tools aim to make  developing distributed software that runs on Kubernetes easier.  Offering the capability to develop inside the container via live reload features.  With this, changes are streamed from the developer’s workstation into the running container whereupon the init process is restarted.  The dev orchestrator, of course, handles most of this by building the changes and copying them in the container but ultimately the running container needs the ability to restart its entrypoint process for the changes to take effect.

Today buildpacks are unable to participate in these live reload development workflows but, moving forward, we would very much like them to be able to.

## Detailed Explanation

We propose creating a utility buildpack that packages the watchexec command line utility for restarting arbitrary processes.

When enabled by a BP_LIVE_RELOAD_ENABLED=true environment variable, the language buildpacks may request the inclusion of watchexec, via the build plan.

This affords language buildpacks the ability to use watchexec for creating a reloadable process type when no better options are available.  For example, the java buildpack may prefer to use spring-boot-devtools if that is available but can always fallback to watchexec otherwise.  

As a result, a language buildpack may produce a reloadable process type such as:

`watchexec -r java org.springframework.boot.loader.JarLauncher`

and in doing so, for the reloadable process type, the buildpack makes watchexec the stable init process for the container that monitors the workspace directory for file changes, restarting the app process when they occur.

Note that watchexec watches the current directory (and below). The working directory is the app directory so all buildpacks wishing to support reloadable process types would need to contribute their entrypoint processes to the app directory.

Note also that watchexec supports shell-less invocation and therefore will be able to support the tiny builder that produces a run image with no shell.  

It also supports windows through both Cmd and Powershell shells. 


## Rationale and Alternatives

In terms of the restart utility we did initially consider [entr](http://eradman.com/entrproject/) but as can be seen from the documentation it relies on bash and that, of course, won't work with the paketo tiny stack. 
