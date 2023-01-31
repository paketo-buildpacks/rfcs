# Reduce duplicated code, allow re-use across sub buildpacks

## Summary

Refactor code which is used in multiple buildpacks/extensions into a single copy usable by all.

## Motivation 

This would reduce duplicated code which would help avoid drift that could result in functional issues as well as reducing the number of different places that the same constants like "package.json" are defined.

It would also allow us to re-use this code in the extension we are building for ubi instead of having to create another copy which could get out of sync.

## Detalied Explanation

As an example of where there is duplicated code, there are at least 3 copies of code which find/builds/checks the project path in the existing sub buildpacks. 

There are two copies of package_json_parser.go
* https://github.com/paketo-buildpacks/npm-start/blob/main/package_json_parser.go
* https://github.com/paketo-buildpacks/npm-install/blob/main/project_path_parser.go

and what looks like another copy embeded into detect.go in node-engine - https://github.com/paketo-buildpacks/node-engine/blob/25db92fd154eb295e4ed621706a82b5f9eed823f/detect.go#L21

Similarly the path to the package.json is built and and a check made if the file exists in a number of places:
* https://github.com/paketo-buildpacks/npm-start/blob/02d58f0a48a92990768b90b47a94ee0c942a71d6/detect.go#LL25-L36C4
* https://github.com/paketo-buildpacks/npm-start/blob/02d58f0a48a92990768b90b47a94ee0c942a71d6/detect.go#LL25-L36C4

A similar case is finding application (https://github.com/paketo-buildpacks/node-start/blob/222bf718ff91d1b7ea178cae5283c40977c6c645/node_application_finder.go). It almost externalizes the logic
except that os.Getenv("BP_LAUNCHPOINT"), os.Getenv("BP_NODE_PROJECT_PATH") are used to get info from the environment which is then passed to the Find method.

## Rational and Alternatives

The rational is that avoiding duplication and drift reduces introducing bugs due to unintended differences between implementations of the same thing.

The alternative is to copy/re-use code from the existing buildpacks. As an example this is how our work in progress re-uses some of the functions:

```go
// functionality from npm-start buildpack, also some overlap with npm-install
func packageJSONExists(workingDir string, projectPathParser npmstart.PathParser) (path string, err error) {

	projectPath, err := projectPathParser.Get(workingDir)
	if err != nil {
		return "", err
	}

	path = filepath.Join(projectPath, "package.json")
	_, err = os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	return path, nil
}

// functionality from node-start
func nodeApplicationExists(workingDir string, applicationFinder nodestart.ApplicationFinder) (path string, err error) {
	return applicationFinder.Find(workingDir, os.Getenv("BP_LAUNCHPOINT"), os.Getenv("BP_NODE_PROJECT_PATH"))
}

along with 

projectPathParser := npmstart.NewProjectPathParser()
nodeApplicationFinder := nodestart.NewNodeApplicationFinder()

in the caller of those functions
```

## Implementation
Create a new package to hold the shared functions or designate one of the existing build packs to centralize the common functions.  Creating a new package to hold the shared functions is probably the better option in terms of limiting cross dependencies.

## Prior Art

## Unresolved Questions and Bikeshedding

How and where to put the shared code.


