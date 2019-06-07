#!/bin/bash
tag_exists () {
    local SHA=$1
    if [[ -z "$SHA" ]]; then
        echo "-- ERROR: there was a problem looking up AMI by sha"
        exit 1
    fi
    EMPTY=$(aws ec2 describe-images --filters Name=tag:SHA,Values=$SHA --query 'Images[*]')
    if [ "$EMPTY" = "[]" ]; then
        echo "false"
    else
        echo "true"
    fi
}

base_rebuilt () {
    local NAME=$1
    if [[ -e "manifest-$NAME.json" ]] && [[ -s "manifest-$NAME.json" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

extract_artifact_id () {
    local NAME="$1"
    local AMI="$(cat manifest-$NAME.json | jq '.builds[0].artifact_id' | awk -F 'us-east-1' '{print $2}' | cut -d',' -f1)"
    echo "${AMI:1}"
}

get_base_ami () {
    local BASE_BUILT=$1
    local DIR=$2
    local NAME=$3
    if [ "$BASE_BUILT" = "false" ]; then
        EXISTING_BASE_SHA="$(git ls-tree HEAD $DIR | cut -d" " -f3 | cut -f1)"
        EXISTING_BASE_IMAGE=$(aws ec2 describe-images --filters Name=tag:SHA,Values=$EXISTING_BASE_SHA --query 'Images[*]' | jq -r '.[0].ImageId')
        echo "$EXISTING_BASE_IMAGE"
    else
        BASE_AMI_US_EAST_1="$(extract_artifact_id $NAME)"
        echo "${BASE_AMI_US_EAST_1}"
    fi
}

package_check () {
    command -v aws > /dev/null || (echo "aws cli must be installed" && exit 1)
    command -v packer > /dev/null || (echo "packer must be installed" && exit 1)
    command -v git > /dev/null || (echo "git must be installed" && exit 1)
    command -v jq > /dev/null || (echo "jq must be installed" && exit 1)
}
