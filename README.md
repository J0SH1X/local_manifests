#Local manifest
To add this manifest to your local repository, use this command in source's root:

git clone git://github.com/StanHardy/local_manifests.git -b master .repo/local_manifests

repo sync --force-sync

make clean && make clobber

export ROOMSERVICE_BRANCHES=cm-14.0

source build/envsetup.sh
. build/envsetup.sh

breakfast h815

brunch h815
