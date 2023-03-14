# minlopro-dx

TODO - Describe the project

## Prerequisites

Install `node` version according to `package.json` file (_19.7.0_). It's recommended to
use [NVM](https://tecadmin.net/install-nvm-macos-with-homebrew/) in order to manage NODE versions on
local machine.

Run `npm install` in order to load project dependencies.

Look through the pre-configured GitHub Workflows/Actions located in `.github/workflows/` folder.

Make sure that the changed codebase files are _prettified_ via `npm run prettier` command.
Alternatively, you can run `npm run prettier:check` in order to identify _non-prettified_ files.

### Branches

_`main`_

Comprises all source code in the repository.

_`develop`_

Used for features development. Descendant of `main` branch. This branch should always be synced up with `main` branch
once the feature(s) has been developed, tested and pushed to release.

Corresponds to **QA** environment.

_`release/**`_

Holds a bundle of features for specific release. Descendant of `develop` branch. Should always be synced up with `main`
branch once the release features have been deployed & tested on production org.

Corresponds to **PROD** environment.

### Useful Commands

_Generate Auth URL for the Target Org_

```
// Authorize Org (defining 'targetOrg' alias)
sfdx auth:web:login --setalias targetOrg
// Generate auth URL and save it to the file './org_auth_url.txt'
sfdx auth:sfdxurl:store -f ./org_auth_url.txt -a targetOrg -d -s
// Print org info
sfdx force:org:display --verbose -a targetOrg
```

_Deploy Repository Source to Target Org_

```
// Create 'package.xml' manifest file that lists all metadata components within the repo
sfdx force:source:manifest:create --sourcepath minlopro --manifestname manifests/package.xml
// Initiate source code deployment
sfdx force:source:deploy \
    -x manifests/package.xml \
    --predestructivechanges manifests/destructiveChangesPre.xml \
    --postdestructivechanges manifests/destructiveChangesPost.xml \
    --checkonly \
    --verbose \
    --testlevel=RunLocalTests \
    --ignorewarnings
```

The following flags are optional:

- `--checkonly` - used to validate bundle deployment
- `--testlevel` - used to invoke Apex Tests during deployment

_Invoke All Apex Tests_

```
sfdx force:apex:test:run --code-coverage --result-format human -d ./coverage
```

 ### Scripts in `package.json`

Aforementioned commands were broken down into smaller ones in `package.json` project file.
Keep im mind that scripts that start with `sfdx:...` or `src:...` can be invoked with extra parameters passed to them.
E.g. you can execute particular script passing in ORG alias:

```
// Authorize Org
npm run sfdx:auth:create -- -u [AUTHORIZED_ORG_ALIAS] && npm run sfdx:auth:store
// Validate deployment to target ORG
npm run sfdx:manifest && npm run src:deploy:check -- -u [AUTHORIZED_ORG_ALIAS]
// Run deployment to target ORG
npm run sfdx:manifest && npm run src:deploy:full -- -u [AUTHORIZED_ORG_ALIAS] --tracksource --forceoverwrite
```

Please, refer to [SFDX CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm) for more information.
