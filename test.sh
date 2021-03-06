#!/bin/bash
echo "**************************************"
echo "            TEST RUN"
echo "**************************************"
#
export IMAGE_NAME="philipstaffordwood/kubular-ansible-agent:latest"

export TERM="xterm"
echo Running in host directory: `pwd`
echo RUNNNING CONTAINER TESTS
docker run \
    --rm \
    -v `pwd`:/src \
    -e TERM=$TERM \
    $IMAGE_NAME \
    bats -p src/tests/test_container.bats
echo "STATUS CODE: $?"
echo RUNNNING INTERNAL TESTS
PWD=`pwd`
CID=`docker run \
    -d \
    --rm \
    -v $PWD:/src \
    -e TERM=$TERM \
    $IMAGE_NAME \
    webhook -verbose -hooks=/src/tests/webhook/hooks.json -hotreload `
docker exec $CID bats -p src/tests/test_webhook.bats
docker rm -f $CID
echo "STATUS CODE: $?"
echo RUNNNING EXTERNAL TESTS
PWD=`pwd`
export CID=`docker run \
    -d \
    --rm \
    -v $PWD:/src \
    -e TERM=$TERM \
    -p 9000:9000 \
    $IMAGE_NAME \
    webhook -verbose -hooks=/src/tests/webhook/hooks.json -hotreload `
bats -p ./tests/test_external.bats
docker rm -f $CID
echo "STATUS CODE: $?"
echo
echo "**************************************"
echo 
