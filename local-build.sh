#!/bin/bash
# Run the aurora-packaging build locally

if [ -z $1 ] ; then
    VERSION=$(git rev-parse --abbrev-ref HEAD)
else
    VERSION=$1
fi

download_dir=.download

mkdir -p $download_dir

# Check if we already have the package
if [ ! -e "apache-aurora-${VERSION}.tar.gz" ] ; then
    # Find the mirror
    MIRROR=$(curl -o - -L "http://www.apache.org/dyn/closer.cgi?as_json=1&path=/aurora/${VERSION}/apache-aurora-${VERSION}.tar.gz" | jq -r '.preferred + .path_info')

    # Download the package
    curl -o $download_dir/apache-aurora-${VERSION}.tar.gz "$MIRROR"
fi

http_proxy= https_proxy= ./build-artifact.sh $download_dir/apache-aurora-${VERSION}.tar.gz ${VERSION}
