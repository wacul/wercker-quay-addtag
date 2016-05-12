#!/bin/sh
set +e
set -o noglob

#
# Headers and Logging
#

error() { printf "✖ %s\n" "$@"
}
warn() { printf "➜ %s\n" "$@"
}
success() { printf "✔ %s\n" "$@"
}

# Check variables
if [ -z "$WERCKER_QUAY_ADDTAG_TOKEN" ]; then
  error "Please set the 'token' variable"
  exit 1
fi
if [ -z "$WERCKER_QUAY_ADDTAG_QUAY_REPOSITORY" ]; then
  error "Please set the 'quay_repository' variable"
  exit 1
fi
if [ -z "$WERCKER_QUAY_ADDTAG_SOURCE_TAG" ]; then
  error "Please set the 'sourcetag' variable"
  exit 1
fi
if [ -z "$WERCKER_QUAY_ADDTAG_ADD_TAG" ]; then
  error "Please set the 'add' variable"
  exit 1
fi


IMAGE_ID=$(curl -f -s -H "authorization: Bearer ${WERCKER_QUAY_ADDTAG_TOKEN}" "https://quay.io/api/v1/repository/${WERCKER_QUAY_ADDTAG_QUAY_REPOSITORY}/tag/${WERCKER_QUAY_ADDTAG_SOURCE_TAG}/images"|jq .images[0].id)

if [ $? -ne 0 ];then
  error "get source image failed"
  exit 1
fi

success "source tag imageid: ${IMAGE_ID}"

curl -s -f -XPUT -d '{ "image" : '"${IMAGE_ID}"' }' -H "authorization: Bearer ${WERCKER_QUAY_ADDTAG_TOKEN}" -H "content-type: application/json" "https://quay.io/api/v1/repository/${WERCKER_QUAY_ADDTAG_QUAY_REPOSITORY}/tag/${WERCKER_QUAY_ADDTAG_ADD_TAG}"

if [ $? -ne 0 ];then
  error "tag adding failed"
  exit 1
fi

success "tag added: ${WERCKER_QUAY_ADDTAG_ADD_TAG}"
