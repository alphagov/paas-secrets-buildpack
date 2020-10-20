#!/usr/bin/env ruby

require 'yaml'
require 'json'

def generate_secrets_profile_d_entry(config_path, index)
    vault = "/home/vcap/deps/#{index}/vault"

    secrets_config = read_secrets_config(config_path)
    app_details = read_app_details()
    write_secrets_for_profile_d(secrets_config, app_details, vault)
end

def read_secrets_config(path)
    return YAML.safe_load(IO.read(path))
end

def read_app_details()
    vcap_application = JSON.parse(ENV["VCAP_APPLICATION"])
    return {
        "app_guid" => vcap_application["application_id"],
        "app_name" => vcap_application["application_name"],
        "space_guid" => vcap_application["space_id"],
        "org_guid" => vcap_application["organization_id"]
    }
end

def write_secrets_for_profile_d(secrets_config, app_details, vault_path)
    # Secrets config is a set of key value pairs in the format
    # ENV_VAR_NAME = path/to/secret:key_within_secret
    #
    # The values can contain certain placeholder strings which are
    # subtituted at runtime
    # $APP_GUID_PATH = path to the app level secrets using the guid, without a trailing slash
    # $APP_NAME_PATH = path to the app level secrets using the name, without a trailing slash
    # $SPACE_PATH = path to space level secrets using the space guid, without a trailing slash
    # $ORG_PATH = path to the org level secrets using the org guid, without a trailing slash

    secrets_pairs = {}

    secrets_config.each do |env_var_name, path_and_key|
        original_path, key = split_configured_path(path_and_key)
        path_without_placeholders = replace_path_placeholders(original_path, app_details)
        secret_value = read_secret_command(vault_path, path_without_placeholders, key)

        secrets_pairs[env_var_name] = secret_value
    end

    joined_export_commands = secrets_pairs
        .map{ |key, value| "export #{key}=#{value}" }
        .join("\n")



    return %Q{
#{vault_path} login -method=cf role=apps

#{joined_export_commands}
    }
end

def replace_path_placeholders(path, app_details)
    org_guid_path = "/cloudfoundry/orgs/#{app_details["org_guid"]}"
    space_guid_path = org_guid_path+"/spaces/#{app_details["space_guid"]}"

    placeholders = {
        "$APP_GUID_PATH" => space_guid_path+"/apps/#{app_details["app_guid"]}",
        "$APP_NAME_PATH" => space_guid_path+"/apps/#{app_details["app_name"]}",
        "$SPACE_PATH" => space_guid_path,
        "$ORG_PATH" => org_guid_path
    }

    subbed_path = path
    placeholders.each do |placeholder, value|
        subbed_path = subbed_path.sub(placeholder, value)
    end

    return subbed_path
end

def split_configured_path(path_and_key)
    parts = path_and_key.split(":")
    return [parts[0], parts[1]]
end

def read_secret_command(vault_path, path, key)
    return "$(#{vault_path} kv get -field=\"#{key}\" \"#{path}\")"
end
