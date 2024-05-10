#!/bin/bash

# How to use:
# - bash ./scripts/automations/create_scratch_org.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

# Capture DevHub org alias;
read -p "🔶 Enter DevHub Alias: " DEV_HUB_ALIAS
# Capture Scratch Org alias;
read -p "🔶 Enter Scratch Org Alias: " SCRATCH_ORG_ALIAS
# Capture Admin email address alias;
read -p "🔶 Enter Admin Email Address: " ADMIN_EMAIL

echo "🔵 Spinning up scratch org [$SCRATCH_ORG_ALIAS] for [$ADMIN_EMAIL] under [$DEV_HUB_ALIAS] dev hub org..."

# Pre-configure Salesforce CLI
sf config set org-capitalize-record-types=true

# Create a brand new scratch org AND set it as a DEFAULT ORG!
sf org create scratch \
    --target-dev-hub "$DEV_HUB_ALIAS" \
    --alias "$SCRATCH_ORG_ALIAS" \
    --definition-file "config/project-scratch-def.json" \
    --admin-email "$ADMIN_EMAIL" \
    --set-default \
    --duration-days 30 \
    --wait 10
sf config list

# Reset Admin User password
sf org generate password --target-org "$SCRATCH_ORG_ALIAS"

# Capture scratch org credentials
mkdir -p "build"
orgCredentialsFile="build/$ADMIN_EMAIL-SO.json"
touch "$orgCredentialsFile"
echo "📜 Scratch Org Credentials"
sf org display --target-org "$SCRATCH_ORG_ALIAS" --verbose --json >> "$orgCredentialsFile"
cat "$orgCredentialsFile"

# Run PRE-deploy scripts
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/pre/run_pre.sh

# Generate project manifest and initiate full deploy to scratch org (this automatically creates Digital Experience Site)
sf project generate manifest --source-dir "src" --name "manifests/package.xml"
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/deploy.sh

# Create QA user
echo "$ADMIN_EMAIL" | bash ./scripts/util/create_qa_user.sh

# Run POST-deploy scripts
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/post/run_post.sh

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/import_sample_data.sh

# Publish Digital Experience Site
sf community publish --name "DigEx" --target-org "$SCRATCH_ORG_ALIAS"
