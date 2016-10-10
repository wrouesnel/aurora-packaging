#!/bin/bash
# Build repositories with apt-ftparchive and upload to IPFS for publication.
# Works by copying all the artifacts to a publish staging location.

if [ ! -x $(which aptly) ]; then
    echo "aptly is not installed!"
    exit 1
fi

if [ -z $KEY ]; then
    echo "Must specify a signing key!"
    exit 1
fi

aptly="$(which aptly) -config=$(pwd)/aptly.conf"

builders=()
for builder in $(ls -1 artifacts) ; do
    builders+=( $builder )

    # Get the distribution name
    distribution=$( echo $builder | sed 's/aurora-.*-//' )
    # Get the codename
    codename=$( echo $distribution | cut -d'-' -f2 )

    $aptly repo create -distribution=$codename -component=main $builder
    $aptly repo add $builder artifacts/$builder/dist
    #ls -1 artifacts/$builder/dist | while read pkg ; do
    #    pkg_version=$( echo $pkg | grep -oP '\d+.\d+.\d+' )
    #    pkg_name=$( echo $pkg | grep -oP '^.*?_' | sed 's/_$//' )
    #    pkg_arch=$( echo $pkg | grep -oP '[^_]*.deb$' | sed 's/\.deb$//' )#

    #    # Copy packages to the dist staging dir
    #    cp -f artifacts/$builder/dist/$pkg $dist_dir/$pkg
    #done

    #orig_dir="$(pwd)"
    $aptly publish repo -gpg-key="$KEY" $builder aurora
done

# export the signing key to the staging dir
gpg --armor --export $KEY > $(jq -r '.rootDir' aptly.conf)/public/aurora/signing-key.asc

