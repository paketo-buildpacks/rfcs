# Add database libraries to Full stack

## Summary

Many users of Paketo buildpacks build applications that connect to databases.
In order to facilitate the onboarding experience of these users into the Paketo
ecosystem, we should add packages to the Full stack that provide the necessary
header files for applications to connect to databases.

Specifically, we should add `libpq-dev` and `libmariadb-dev` to the Full stack.

## Motivation

We want to make it easy for application developers to try out Paketo buildpacks
to build applications that connect to databases. This is a common pattern, and
one that we should support out-of-the-box.

Currently in order to build such an application, consumers must also first
build their own stack. This is a significant increase in effort and may cause
application developers to rule out Paketo Buildpacks as an option for building
their applications.

Additionally, for customers who are willing to use the Full stack as-is and
who value timely security updates, building their own stack also incurs the
ongoing maintenance burden of keeping this stack up to date.

The Full stack is positioned to optimize onboarding experience for most typical
applications, at the expense of file size and security surface area. It is
reasonable that this definition of "typical applications" includes applications
that connect to databases.

These database libraries have many dependencies (see below for more details) so
we must balance the improved user experience with the increased security risk
from more packages. Adding the libraries to the Full stack offers an acceptable
compromise.

## Detailed Explanation

For the Ubuntu 18.04 (Bionic) Full stack and Ubuntu 22.04 (Jammy) Full stacks,
we should add the following packages to the `stack.toml` files:

* libmariadb-dev
* libpq-dev

### Dependent packages

On Ubuntu 18.04 (Bionic), we see the following dependent packages:

#### libmariadb-dev

```
libmariadb3
libssl1.1
```

#### libpq-dev

```
libasn1-8-heimdal
libgssapi-krb5-2
libgssapi3-heimdal
libhcrypto4-heimdal
libheimbase1-heimdal
libheimntlm0-heimdal
libhx509-5-heimdal
libk5crypto3
libkeyutils1
libkrb5-26-heimdal
libkrb5-3
libkrb5support0
libldap-2.4-2
libldap-common
libpq5
libroken18-heimdal
libsasl2-2
libsasl2-modules-db
libsqlite3-0
libssl1.1
libwind0-heimdal
```

On Ubuntu 22.04 (Jammy) we see the following dependent packages:

#### libmariadb-dev

```
fontconfig-config
fonts-dejavu-core
libbrotli1
libbsd0
libc-dev-bin
libc-devtools
libc6-dev
libcrypt-dev
libdeflate0
libexpat1
libfontconfig1
libfreetype6
libgd3
libjbig0
libjpeg-turbo8
libjpeg8
libmariadb3
libmd0
libnsl-dev
libpng16-16
libssl-dev
libssl3
libtiff5
libtirpc-dev
libwebp7
libx11-6
libx11-data
libxau6
libxcb1
libxdmcp6
libxpm4
linux-libc-dev
manpages
manpages-dev
mariadb-common
mysql-common
rpcsvc-proto
ucf
zlib1g
zlib1g-dev
```

#### libpq-dev

```
libldap-2.5-0
libldap-common
libpq5
libsasl2-2
libsasl2-modules
libsasl2-modules-db
libssl-dev
libssl3
```

## Rationale and Alternatives

* Do not add the packages to any stack: continue to require users to build
  their own stacks. As mentioned above, this is a poor onboarding experience
  for consumers who are getting started with Paketo Buildpacks with
  applications that connect to databases, which is a common use-case that
  Paketo should support.
* Add the packages to the Base stack as well as the Full stack.
  However, as can be seen above, these packages bring in a lot of dependencies
  and therefore significantly increase the surface area of the stacks. This is
  an acceptable trade-off for the Full stack, as that stack is intended to make
  onboarding easy at the expense of security, whereas the Base stack is
  intended to be closer to a production environment.
  This solution only improves the onboarding experience marginally, as the Full
  stack would have the packages either way and this solution just widens the
  support to include the Base stack.

## Implementation

For the Ubuntu 18.04 (Bionic) Full stack and Ubuntu 22.04 (Jammy) Full stacks,
we propose adding the following packages to the `stack.toml` files:

* libmariadb-dev
* libpq-dev

As soon as they are committed, the automation will build and publish new stacks.

## Prior Art

The CloudFoundry cflinuxfs3 stack contains both the
[`libmariadb-dev`](https://github.com/cloudfoundry/cflinuxfs4/blob/26ed0a627bf521daa31e42cb22fccc7df405b083/receipt.cflinuxfs4.x86_64#L399)
and
[`libpq-dev`](https://github.com/cloudfoundry/cflinuxfs3/blob/770f41c34165096de7cf2bc7a166e6ee3e5ac587/receipt.cflinuxfs3.x86_64#L400)
packages.

Similarly, the CloudFoundry cflinuxfs4 stack contains both the
[`libmariadb-dev`](https://github.com/cloudfoundry/cflinuxfs4/blob/26ed0a627bf521daa31e42cb22fccc7df405b083/receipt.cflinuxfs4.x86_64#L325)
and
[`libpq-dev`](https://github.com/cloudfoundry/cflinuxfs4/blob/26ed0a627bf521daa31e42cb22fccc7df405b083/receipt.cflinuxfs4.x86_64#L399)
packages.

## Unresolved Questions and Bikeshedding

- We don't really have a good definition for what constitutes an application we
  would want to support vs one that we think is outside of what Paketo should
  support out-of-the-box. Phrased another way, why is it ok to add these
  packages but not others? Where do we draw the line?
