#!/usr/bin/env bash

if [ "x$1" == "x" ] || [ "x$2" == "x" ]; then
  echo "./build.sh raven-dir number-of-processes" >&2
  echo "           for example: ./build.sh ../ 4" >&2
  echo "more processes = faster build, more CPU" >&2
  exit 1
fi


RAVENPATH=`realpath "${1/#\~/$HOME}"`

if [ ! -f $RAVENPATH/src/ravend.cpp ]; then
  echo "First parameter doesn't seem like a raven path" >&2
  echo "" >&2
  echo "./build.sh raven-dir number-of-processes" >&2
  echo "           for example: ./build.sh ../ 4" >&2
  echo "more processes = faster build, more CPU" >&2

  exit 1
fi

re='^[0-9]+$'
if ! [[ $2 =~ $re ]] ; then
  echo "Second parameter not a number" >&2
  echo "" >&2
  echo "./build.sh raven-dir number-of-processes" >&2
  echo "           for example: ./build.sh ../ 4" >&2
  echo "more processes = faster build, more CPU" >&2

  exit 1
fi

set -ex

docker build -t ravend_build .

docker run -v $RAVENPATH:/raven ravend_build /run.sh $2

cd $RAVENPATH/out

# renaming from raven name to Bitcore name.... stupid thing
rm -f $RAVENPATH/out/raven-0.14.0-x86_64-linux-gnu-debug.tar.gz
rename s/x86_64-linux-gnu/linux64/ $RAVENPATH/out/*.tar.gz

sha256sum *.tar.gz > SHA256SUMS
gpg --digest-algo sha256 --clearsign SHA256SUMS
