#!/bin/bash

PR_NUMBER=$1
BUCKET_URL="s3://richardresults/ray-wheels/"
TEMPLATE_YAML="./wheel-template.yaml"
TMP_YAML="./tmp_ray_yaml.yaml"
TEMPLATE_SCRIPT="./scripts/run_builder_template.sh"
TMP_SCRIPT="./scripts/tmp_run_builder.sh"
PWD=$(pwd)

echo "Building $PR_NUMBER from $PWD"
cat $TEMPLATE_SCRIPT | \
    sed 's|<<<PR_NUMBER>>>|'"$PR_NUMBER"'|' | \
    sed 's|<<<BUCKET_URL>>>|'"$BUCKET_URL"'|' | \
    sed 's|<<<PWD>>>|'"$PWD"'|' > $TMP_SCRIPT
cat $TEMPLATE_YAML | \
    sed 's|<<<TMP_SCRIPT>>>|'"$TMP_SCRIPT"'|' | \
    sed 's|<<<PWD>>>|'"$PWD"'|' > $TMP_YAML

ray create_or_update $TMP_YAML -y
ray exec --screen --stop $TMP_YAML "bash $TMP_SCRIPT"
