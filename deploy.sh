#!/bin/bash
set -e

DISTRIBUTION_ID=E1ZTFHJ6XDJ8NZ
BUCKET_NAME=squig.gs
PROFILE=mine

rm -rf public
sass --update sass:static/css --sourcemap=none --style=compressed
hugo -v

aws s3 sync --profile ${PROFILE} --acl "public-read" --sse "AES256" public/ s3://${BUCKET_NAME}/ --delete --exclude 'js' --exclude 'css' --exclude 'fonts' --exclude '*.DS_Store'

# Ensure static files are set to cache forever - cache for a month --cache-control "max-age=2592000"
aws s3 sync --profile ${PROFILE} --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/fonts/ s3://${BUCKET_NAME}/fonts/ --delete --exclude '*.DS_Store'
aws s3 sync --profile ${PROFILE} --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/css/ s3://${BUCKET_NAME}/css/ --delete --exclude '*.DS_Store'
aws s3 sync --profile ${PROFILE} --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/js/ s3://${BUCKET_NAME}/js/ --delete --exclude '*.DS_Store'

# Invalidate landing page so everything sees new post - warning, first 1K/mo free, then 1/2 cent each
aws cloudfront create-invalidation --profile ${PROFILE} --distribution-id ${DISTRIBUTION_ID} --paths /index.html /
