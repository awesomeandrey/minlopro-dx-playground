#!/usr/bin/env bash

# How to use:
# - bash ./scripts/deploy/deploy.sh
# - echo 'ORG_ALIAS' | bash ./scripts/deploy/deploy.sh

# Capture target org alias;
read -r -p "🔶 Enter target org alias to run hard deploy against: " TARGET_ORG_ALIAS

# Define constants;
manifestsFolder="manifests"
packageXml="$manifestsFolder/package.xml"
preDestructiveChangesXml="$manifestsFolder/destructiveChangesPre.xml"
postDestructiveChangesXml="$manifestsFolder/destructiveChangesPost.xml"

# Verify that all 3 manifests exist and are valid;
if ! xmllint --noout "$packageXml" "$preDestructiveChangesXml" "$postDestructiveChangesXml"; then
  echo "🔴 'manifests' folder must contain 3 manifest files: package.xml, destructiveChangesPre.xml & destructiveChangesPost.xml."
  exit 1
fi

# Check there are no metadata references in manifest files;
if ! grep -q '<members>' "$packageXml" && ! grep -q '<members>' "$preDestructiveChangesXml" && ! grep -q '<members>' "$postDestructiveChangesXml"; then
  echo "⚪ There are no metadata changes detected!"
  exit 0
fi

# Invoke source deploy to target org;
echo "🔵 Deploying to [$TARGET_ORG_ALIAS] organization..."

# Ingest environment variables & deploy;
npx dotenv -e ".env" -- sf project deploy start \
  --target-org "$TARGET_ORG_ALIAS" \
  --manifest "$packageXml" \
  --pre-destructive-changes "$preDestructiveChangesXml" \
  --post-destructive-changes "$postDestructiveChangesXml" \
  --ignore-conflicts \
  --ignore-warnings \
  --concise \
  --wait 20
