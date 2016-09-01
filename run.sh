#!/bin/sh
set +e
set -o noglob


type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

#
# Headers and Logging
#

error() { printf "✖ %s\n" "$@"
}
warn() { printf "➜ %s\n" "$@"
}
success() { printf "✔ %s\n" "$@"
}

# Check jq is installed
if ! type_exists 'jq'; then
  sudo curl -s -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && sudo chmod +x /usr/local/bin/jq
fi

# Check variables
if [ -z "$WERCKER_QUAY_ADDTAG_TOKEN" ]; then
  error "Please set the 'token' variable"
  exit 1
fi
if [ -z "$WERCKER_QUAY_ADDTAG_REPOSITORY" ]; then
  error "Please set the 'repository' variable"
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

export WERCKER_QUAY_ADDTAG_REPOSITORY=$(echo ${WERCKER_QUAY_ADDTAG_REPOSITORY} | sed "s/^quay\.io\///g")

success "source tag: ${WERCKER_QUAY_ADDTAG_SOURCE_TAG}"

IMAGE_ID=$(curl -f -s -H "authorization: Bearer ${WERCKER_QUAY_ADDTAG_TOKEN}" "https://quay.io/api/v1/repository/${WERCKER_QUAY_ADDTAG_REPOSITORY}/tag/${WERCKER_QUAY_ADDTAG_SOURCE_TAG}/images"|jq .images[0].id)

if [ $? -ne 0 ];then
  error "get source image failed"
  exit 1
fi

success "source tag imageid: ${IMAGE_ID}"

curl -s -f -XPUT -d '{ "image" : '"${IMAGE_ID}"' }' -H "authorization: Bearer ${WERCKER_QUAY_ADDTAG_TOKEN}" -H "content-type: application/json" "https://quay.io/api/v1/repository/${WERCKER_QUAY_ADDTAG_REPOSITORY}/tag/${WERCKER_QUAY_ADDTAG_ADD_TAG}"

if [ $? -ne 0 ];then
  error "tag adding failed"
  exit 1
fi

success "tag added: ${WERCKER_QUAY_ADDTAG_ADD_TAG}"
