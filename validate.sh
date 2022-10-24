#!/bin/bash
echo "running validate"
mkdir build -p

lint () {

    FOLDER=$1
    USER=$(id -u)
    GROUP=$(id -g)

    docker run --rm --user $USER:$GROUP -v $(pwd):/wrk -w /wrk  \
        cytopia/yamllint $FOLDER

    if [ $? -ne 0 ]; then
        echo "$FOLDER contained lint failures"
        exit 1
    fi
}

kustomize () {

    FOLDER=$1
    USER=$(id -u)
    GROUP=$(id -g)

    #rm build.yaml
    docker run  --rm --user $USER:$GROUP -v $(pwd):/wrk -w /wrk  \
        nekottyo/kustomize-kubeval kustomize build $FOLDER --load_restrictor=LoadRestrictionsNone > build/${FOLDER///}.yaml

    if [ $? -ne 0 ]; then
        echo "$FOLDER contained kustomization validation failures"
        exit 1
    fi
}

# linting
echo "linting base"
lint apps/base
lint infrastructure/base

for i
do
    echo "linting $i"
    lint apps/$i
    lint infrastructure/$i
done


#build using kustomize
for i
do
    echo "building $i using kustomize"
    kustomize infrastructure/$i
    split infrastructure/$i
    kustomize apps/$i
    split apps/$i
done
