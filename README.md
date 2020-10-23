# paas-secrets-buildpack

CloudFoundry buildpack used by apps to get secrets out of Vault and in to environment variables.

## Usage
```
---
NOTIFY_API_KEY: "$ORG_PATH/notify:api_key"
AWS_ACCESS_KEY_ID: "$APP_GUID_PATH/aws:AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY: "$APP_GUID_PATH/aws:AWS_SECRET_ACCESS_KEY"
```

Add an `app-secrets.yml` file to the root of your app. It describes which environment variables should hold which secret value.

To map a particular secret value, provide its path, a colon, and the key within that secret. For example: `path/to/secret:key`.

## Placeholders
Paths for secrets in GOV.UK PaaS always the org guid of the org, and can also contain the space and app guids. Since they cannot be known at development time, the buildpack provides a number of placeholders that get substituted at runtime.

Secret paths can contain a number of placeholders, which are substituted when the app starts up

* `$ORG_PATH` path to the org level secrets using the org guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123`
* `$SPACE_PATH` path to space level secrets using the space guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456`
* `$APP_GUID_PATH` path to the app level secrets using the guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456/apps/guid-789`
* `$APP_NAME_PATH` path to the app level secrets using the name, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456/apps/app-name`

**Why not `secrets.yml`?**

Ruby on Rails got there first.
