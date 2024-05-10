#!/bin/bash

# How to use:
# - bash ./scripts/automations/create_crma_scratch_org.sh
# - echo $TXT_WITH_INPUTS | bash ./scripts/automations/create_crma_scratch_org.sh

# Enable errexit option to exit on command failure
set -e

# Capture DevHub org alias;
read -p "🔶 Enter CRM Analytics DevHub Alias: " DEV_HUB_ALIAS
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
    --definition-file "config/crma-scratch-def.json" \
    --admin-email "$ADMIN_EMAIL" \
    --set-default \
    --duration-days 30 \
    --wait 10
sf config list

# Reset Admin User password
sf org generate password --target-org "$SCRATCH_ORG_ALIAS"

# Capture scratch org credentials
mkdir -p "build"
orgCredentialsFile="build/$ADMIN_EMAIL-CRMA-SO.json"
touch "$orgCredentialsFile"
echo "📜 CRMA Scratch Org Credentials"
sf org display --target-org "$SCRATCH_ORG_ALIAS" --verbose --json >> "$orgCredentialsFile"
cat "$orgCredentialsFile"

# Resolve ".env" file for the scratch org (this properly resolves 'SF_USERNAME' & 'SF_INSTANCE_URL' variables)
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/pre/custom/resolve_env_variables.sh

# Grab newly created scratch org username
SF_USERNAME=$(bash ./scripts/util/get_target_org_username.sh)
echo "CRMA username: $SF_USERNAME"

# Set custom user name
sf data update record \
  --sobject "User" \
  --where "Username='$SF_USERNAME'" \
  --values "FirstName='Admin' LastName='CRMA'" \
  --target-org "$SCRATCH_ORG_ALIAS"

# Assign 'CRM Analytics Plus' Permission Set License (PSL) to admin user
sf org assign permsetlicense \
  --name "CRM Analytics Plus" \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --on-behalf-of "$SF_USERNAME"

# Assign CRM Analytics permission sets (OOB/standard ones)
sf org assign permset \
  --name "force__EinsteinAnalyticsPlusAdmin" \
  --name "force__EinsteinAnalyticsPlusUser" \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --on-behalf-of "$SF_USERNAME"

# Determine OS and define 'sed' command based on OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    # MacOS
    echo "SED command is adapted for Mac OS."
    SED_COMMAND="sed -i '' "
else
    # Linux
    echo "SED command is adapted for Linux OS."
    SED_COMMAND="sed -i "
fi

# Make sure that 'minlopro-crma' folder is un-ignored in '.forceignore' file
$SED_COMMAND '/minlopro-crma/ s/^/#/' ".forceignore"

# Deploy 'minlopro-crma' folder content
sf project generate manifest \
  --source-dir "src/minlopro-crma" \
  --name "manifests/package.xml"
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/deploy.sh

# Assign remaining permission sets
sf org assign permset \
  --name "CRMA_ObjectsAccess" \
  --name "CrmAnalyticsAdmin" \
  --name "CrmAnalyticsUser" \
  --target-org "$SCRATCH_ORG_ALIAS" \
  --on-behalf-of "$SF_USERNAME"

# Deploy standard duplicate rules as inactive
sf project generate manifest \
  --source-dir "src/minlopro/main/duplicateRules/standard" \
  --name "manifests/package.xml"
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/deploy/deploy.sh

# Import sample data
echo "$SCRATCH_ORG_ALIAS" | bash ./scripts/util/import_sample_data.sh