#!/bin/bash
# Build repositories with apt-ftparchive and upload to IPFS for publication.
# Works by copying all the artifacts to a publish staging location.

if [ -z $KEY ]; then
    echo "Must specify a signing key!"
    exit 1
fi

staging_dir=.ipfs-staging/aurora
mkdir -p $staging_dir

ls -1 artifacts | while read builder ; do
    # Get the distribution name
    distribution=$( echo $builder | sed 's/aurora-.*-//' )
    # Get the codename
    codename=$( echo $distribution | cut -d'-' -f2 )

    dist_dir=$staging_dir/deb/$distribution

    # Write the apt-ftparchive config
    mkdir -p $dist_dir
    cat << EOF > $dist_dir/apt-ftparchive.conf
APT::FTPArchive::Release::Codename "$codename";
APT::FTPArchive::Release::Origin "aurora";
APT::FTPArchive::Release::Components "main";
APT::FTPArchive::Release::Label "wrouesnel";
APT::FTPArchive::Release::Architectures "amd64";
APT::FTPArchive::Release::Description "IPFS repository for aurora"; 
EOF
        
    ls -1 artifacts/$builder/dist | while read pkg ; do
        pkg_version=$( echo $pkg | grep -oP '\d+.\d+.\d+' )
        pkg_name=$( echo $pkg | grep -oP '^.*?_' | sed 's/_$//' )
        pkg_arch=$( echo $pkg | grep -oP '[^_]*.deb$' | sed 's/\.deb$//' )

        # Copy packages to the dist staging dir
        cp -f artifacts/$builder/dist/$pkg $dist_dir/$pkg
        
        #curl -T artifacts/$builder/dist/$pkg \
        #    -u$USER:$API_KEY \
        #    https://api.bintray.com/content/$USER/aurora/$pkg_name/$pkg_version/$pkg;deb_distribution=$distribution;deb_component=main;deb_architecture=$pkg_arch;publish=1
    done

    orig_dir="$(pwd)"
    # create apt-archive for the sub dir
    cd "$dist_dir"
    apt-ftparchive packages -c apt-ftparchive.conf . > Packages 
    apt-ftparchive sources -c apt-ftparchive.conf . > Sources
    apt-ftparchive release -c apt-ftparchive.conf . > Release

    gpg --yes --default-key $KEY -abs -o Release.gpg Release 
    
            # --no-options --no-default-keyring \
            #--secret-keyring $PBUILDER_REPO/pbuilder-secret.gpg \
            #--keyring $PBUILDER_REPO/pbuilder-public.gpg \
            #--trustdb-name $PBUILDER_REPO/trustdb.gpg \
    cd "$orig_dir"
done

# export the signing key to the staging dir
gpg --armor --export $KEY > $staging_dir/signing-key.asc

