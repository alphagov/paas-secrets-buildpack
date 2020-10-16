# paas-secrets-buildpack

CloudFoundry buildpack used by apps to get secrets out of Vault and in to environment variables.

## Usage
Add an `app-secrets.yml` file to the root of your app. The keys are the name of the desired environment variable, and the values are the names of the secrets

The name of a secret is the path to the secret, and the key within that secret, separated by a colon: `/path/to/secret:key`.

Secret paths can contain a number of placeholders, which are substituted when the app starts up

* `$ORG_PATH` path to the org level secrets using the org guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123`
* `$SPACE_PATH` path to space level secrets using the space guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456`
* `$APP_GUID_PATH` path to the app level secrets using the guid, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456/apps/guid-789`
* `$APP_NAME_PATH` path to the app level secrets using the name, without a trailing slash
    e.g. `/cloudfoundry/orgs/guid-123/spaces/guid-456/apps/app-name`


Example `app-secrets.yml`

```
---
NOTIFY_API_KEY: "$ORG_PATH/notify:api_key"
AWS_ACCESS_KEY_ID: "$APP_GUID_PATH/aws:AWS_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY: "$APP_GUID_PATH/aws:AWS_SECRET_ACCESS_KEY"
```

**Why not `secrets.yml`?**

Ruby on Rails got there first.
