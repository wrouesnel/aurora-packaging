#!/bin/bash
# Deploy built ubuntu repositories to ipfs.

# Check ipfs is up and running
if [ ! -x $(which ipfs) ]; then
    echo "ipfs not found or not executable."
    exit 1
fi

if ! ipfs id > /dev/null ; then
    echo "ipfs repository not available or not running"
    exit 1
fi

staging_dir=$(jq -r '.rootDir' aptly.conf)/public/aurora

if [ ! -d "$staging_dir" ]; then
    echo "No staging directory found. Did you run ./build-repositories.sh ?"
    exit 1
fi

result=$(ipfs add -w -r $staging_dir | tail -n1)
if [ $? != "0" ]; then
    echo "ipfs upload failed."
    exit 1
fi

echo "Aurora repositories deployed:"
new_hash=$(echo $result | cut -d' ' -f2)
echo "/ipfs/$new_hash/aurora"

# Update ipns
ipfs name publish $new_hash
