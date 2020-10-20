home = ENV["HOME"]
secrets_url = ENV["VAULT_ADDR"]
tmp_dir = ENV["TMPDIR"]

puts %Q{
pid_file = "#{home}/agent-pidfile"

vault {
    address = "#{secrets_url}"
}

listener "tcp" {
    address = "localhost:9999"
    tls_disable = true
}

cache {
    use_auto_auth_token = true
}

auto_auth {
    method "cf" {
        config = {
            role = "apps"
        }
    }

    sink "file" {
        wrap_ttl = "5m"

        config = {
            path = "#{tmp_dir}/vault-token"
        }
    }
}
}
