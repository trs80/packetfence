#!/bin/bash
set -o nounset -o pipefail -o errexit

# full path to dir of current script
SCRIPT_DIR=$(readlink -e $(dirname ${BASH_SOURCE[0]}))

# full path to root of PF sources
# remove last component of path using bash susbtitution parameters
PF_SRC_DIR=${SCRIPT_DIR%/*}

# source variables from other files
# tr is to remove spaces between "="
source <(grep 'KNK_REGISTRY_URL' ${PF_SRC_DIR}/config.mk | tr -d ' ')
source <(grep 'LOCAL_REGISTRY' ${PF_SRC_DIR}/config.mk | tr -d ' ')
source ${PF_SRC_DIR}/conf/build_id

configure_and_check() {
    DOCKERFILE_DIRS=$(find ${SCRIPT_DIR} -type f -name "Dockerfile" -printf "%P\n")
    for file in ${DOCKERFILE_DIRS}; do
	# remove /Dockerfile suffix
	CONTAINERS_IMAGES+=" ${file%/Dockerfile}"
    done
    
    echo "Images detected:"
    for img in ${CONTAINERS_IMAGES}; do
	echo "- $img"
    done
}

pull_images() {
    for img in ${CONTAINERS_IMAGES}; do
	docker pull ${KNK_REGISTRY_URL}/${img}:${TAG_OR_BRANCH_NAME}
    done
}

tag_images() {
    for img in ${CONTAINERS_IMAGES}; do
	docker tag ${KNK_REGISTRY_URL}/${img}:${TAG_OR_BRANCH_NAME} ${LOCAL_REGISTRY}/${img}:${TAG_OR_BRANCH_NAME}
    done
}

configure_and_check

pull_images

tag_images
