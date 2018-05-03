#!/usr/bin/env bash

set -e

LOG=/var/log/user_data.log
METADATA_URL="http://169.254.169.254/latest/meta-data"
DYNDATA_URL="http://169.254.169.254/latest/dynamic"
INSTANCE_ID="$(curl -s $METADATA_URL/instance-id)"
HOSTNAME="$(curl -s $METADATA_URL/local-hostname)"

function log() {
    ts=$(date '+%Y-%m-%dT%H:%M:%SZ')
    printf '%s [init.sh] %s\n' "$ts" "$1" | tee -a "$LOG"
}

yum update -y

yum upgrade -y --enablerepo=epel >"$LOG"

if ! which wget >/dev/null; then
    yum install -y wget >"$LOG"
fi
if ! which unzip >/dev/null; then
    yum install -y unzip >"$LOG"
fi
if ! which ruby >/dev/null; then
    yum install -y ruby >"$LOG"
fi
if ! which jq >/dev/null; then
    log "Installing jq.."
    yum install -y --enablerepo=epel jq >"$LOG"
fi

log "Determining region this instance is in.."
REGION="$(curl -s $DYNDATA_URL/instance-identity/document | jq -r '.region')"
log "Region is: $REGION"

log "Installing CodeDeploy agent.."
pushd /home/ec2-user
aws s3 cp "s3://aws-codedeploy-$REGION/latest/install" . --region="$REGION" >"$LOG"
chmod +x ./install
./install auto >"$LOG"
service codedeploy-agent stop >"$LOG"
log "CodeDeploy agent installed successfully!"

log "Fetching instance tags.."
aws ec2 describe-tags --region="$REGION" --filters "Name=resource-id,Values=$INSTANCE_ID" > tags.json
tags="$(jq '.Tags[] as $t | if ($t["Key"] | contains(":") | not) then "\($t["Key"])=\($t["Value"])" else "" end' --raw-output tags.json | awk NF)"
log "$(printf 'Tags:\n%s' "$tags")"

# PREFIX and CHAIN are key to configuring this instance
PREFIX="$(jq '.Tags[] | select(.Key == "prefix") | .Value' tags.json --raw-output)"
CHAIN="$(jq '.Tags[] | select(.Key == "chain") | .Value' tags.json --raw-output)"

log "Setting up application environment.."

mkdir -p /opt/app
chown -R ec2-user /opt/app

log "Creating explorer systemd service.."

cat <<EOF > /lib/systemd/system/explorer.service
[Unit]
Description=POA Explorer
After=network.target

[Service]
Type=simple
StandardOutput=journal
StandardError=journal
SyslogIdentifier=explorer
User=ec2-user
WorkingDirectory=/opt/app
ExecStart=/opt/elixir/bin/mix phx.server
Environment="MIX_ENV=prod"
EnvironmentFile=/etc/environment
KillMode=process
TimeoutStopSec=60
Restart=on-failure
RestartSec=5
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

log "Installing Erlang.."

wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm >"$LOG"
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm >"$LOG"
yum install -y \
    erlang-erts \
    erlang-kernel \
    erlang-stdlib \
    erlang-compiler \
    erlang-asn1 \
    erlang-crypto \
    erlang-debugger \
    erlang-dialyzer \
    erlang-edoc \
    erlang-erl_interface \
    erlang-eunit \
    erlang-hipe \
    erlang-inets \
    erlang-mnesia \
    erlang-os_mon \
    erlang-parsetools \
    erlang-public_key \
    erlang-runtime_tools \
    erlang-sasl \
    erlang-ssh \
    erlang-ssl \
    erlang-syntax_tools \
    erlang-tools \
    >"$LOG"

log "Installing Elixir to /opt/elixir.."
mkdir -p /opt/elixir
wget https://github.com/elixir-lang/elixir/releases/download/v1.6.4/Precompiled.zip >"$LOG"
unzip Precompiled.zip -d /opt/elixir >"$LOG"
log "Elixir installed successfully!"

log "Fetching configuration from Parameter Store..."
parameters_json=$(aws ssm get-parameters-by-path --region "$REGION" --path "/$PREFIX/$CHAIN")
params=$(echo "$parameters_json" | jq '.Parameters[].Name' --raw-output)
log "$(printf 'Found the following parameters:\n\n%s\n' "$params")"

function get_param() {
    echo "$parameters_json" |\
    jq ".Parameters[] | select(.Name == \"/$PREFIX/$CHAIN/$1\") | .Value" \
        --raw-output
}

DB_USER="$(get_param 'db_username')"
DB_PASS="$(get_param 'db_password')"
DB_HOST="$(get_param 'db_host')"
DB_PORT="$(get_param 'db_port')"
DB_NAME="$CHAIN"
DATABASE_URL="postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT"

# Need to map the Parameter Store response to a set of NAME="<value>" entries,
# one per line, which will then be written to /etc/environment so that they are
# set for all users on the system
old_env="$(cat /etc/environment)"
{
    echo "$old_env"
    # shellcheck disable=SC2016
    echo 'PATH=/opt/elixir/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH'
    # shellcheck disable=SC1117
    echo "$parameters_json" | \
        jq ".Parameters[] as \$ps | \"\(\$ps[\"Name\"] | gsub(\"-\"; \"_\") | ltrimstr(\"/$PREFIX/$CHAIN/\") | ascii_upcase)=\\\"\(\$ps[\"Value\"])\\\"\"" --raw-output
    echo "DYNO=\"$HOSTNAME\""
    echo "HOSTNAME=\"$HOSTNAME\""
    echo "DATABASE_URL=\"$DATABASE_URL/$DB_NAME\""
} > /etc/environment

log "Parameters have been written to /etc/environment successfully!"

log "Creating pgsql database for $CHAIN"

if ! which psql >/dev/null; then
    log "Installing psql.."
    yum install -y --enablerepo=epel postgresql >"$LOG"
fi

function has_db() {
    psql --tuples-only --no-align \
        "$DATABASE_URL/postgres" \
        -c "SELECT COUNT(*) FROM pg_catalog.pg_database WHERE datname = '$DB_NAME';"
}

if [ "$(has_db)" != "1" ]; then
    psql "$DATABASE_URL/postgres" \
        -c "CREATE DATABASE $DB_NAME;" >"$LOG"
fi

log "Application environment is ready!"

log "Starting CodeDeploy agent.."
service codedeploy-agent start >"$LOG"

exit 0
