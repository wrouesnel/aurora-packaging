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

staging_dir=.ipfs-staging/aurora

if [ ! -d .ipfs-staging ]; then

fi

root_hash=$(ipfs add -w $staging_dir | tail -n1)

echo "Aurora repositories deployed: /ipfs/$root_hash/aurora"
