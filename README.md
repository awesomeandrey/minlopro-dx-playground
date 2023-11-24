# minlopro-dx

[![Deploy Source](https://github.com/awesomeandrey/minlopro-dx-playground/actions/workflows/deploy_workflow.yml/badge.svg)](https://github.com/awesomeandrey/minlopro-dx-playground/actions/workflows/deploy_workflow.yml)

## Prerequisites

Install `node` version specified in `package.json` file. It's recommended to
use [NVM](https://tecadmin.net/install-nvm-macos-with-homebrew/) in order to manage NODE versions on local machine.

Run `bash ./scripts/deploy/build.sh` in order to load project dependencies.

Look through the pre-configured GitHub Workflows/Actions located in `.github/workflows/` folder.

Familiarise yourself with Salesforce environments involved and automations built around them:

![Salesforce Development Workflow](.github/Salesforce_Development_Workflow.png)

Make sure that the changed codebase files are _prettified_ via `npm run prettier` command.
Alternatively, you can run `npm run prettier:check` in order to identify _non-prettified_ files.

### Branches

_`main`_

Comprises all source code in the repository.

_`develop`_

Used for features development. Descendant of `main` branch. This branch should always be synced up with `main` branch
once the feature(s) has been developed, tested and pushed to release.

### Useful Commands

_Create Scratch Org_

```
sf org create scratch \
    --target-dev-hub $DEV_HUB_ALIAS \
    --alias $SCRATCH_ORG_ALIAS \
    --definition-file config/project-scratch-def.json \
    --set-default \
    --edition enterprise \
    --duration-days 30
```

_Create DigEx Site_

```
sf community create \
    --target-org $SCRATCH_ORG_ALIAS \
    --name "DigEx" \
    --template-name "Build Your Own" \
    --url-path-prefix digex
```

_Deploy Codebase_

```
npm run sf:manifest:create && npm run src:deploy:full
```

_Publish Community_

```
sf community publish \
    --name "DigEx" 
    --target-org $SCRATCH_ORG_ALIAS
```

_Retrieve Metadata From Org by `package.xml` File_

```
sf project retrieve start \
    --manifest manifests/package.xml \
    --target-org $SCRATCH_ORG_ALIAS \
    --output-dir build
```

_Generate User Password_

```
sf org generate password --target-org $SCRATCH_ORG_ALIAS 
sf org display user --target-org $SCRATCH_ORG_ALIAS
```

### Scripts in `package.json`

Aforementioned commands were broken down into smaller ones in `package.json` project file.
Keep im mind that scripts that start with `sf:...` or `src:...` can be invoked with extra parameters passed to them.
E.g. you can execute particular script passing in ORG alias:

```
// Push source to target org
npm run src:push -- -o $SCRATCH_ORG_ALIAS
```

Please, refer
to [SF CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_unified.htm)
for more information.
