#!/usr/bin/env bash

#ELIXIR_VERSION and BS_RELEASE should be defined as environment variables
set -e -x

LOG=/var/log/user_data.log
METADATA_URL="http://169.254.169.254/latest/meta-data"
DYNDATA_URL="http://169.254.169.254/latest/dynamic"
INSTANCE_ID="$(curl -s $METADATA_URL/instance-id)"
HOSTNAME="$(curl -s $METADATA_URL/local-hostname)"

function log() {
    ts=$(date '+%Y-%m-%dT%H:%M:%SZ')
    printf '%s [init.sh] %s\n' "$ts" "$1" | tee -a "$LOG"
}

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -P /tmp

yum localinstall -y /tmp/epel-release-latest-7.noarch.rpm

yum update -y

yum upgrade -y --enablerepo=epel >"$LOG"

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
if ! which git >/dev/null; then
    log "Installing git.."
    yum install -y --enablerepo=epel git >"$LOG"
fi
if ! which libtool >/dev/null; then
    log "Installing libtool.."
    yum install -y libtool >"$LOG"
fi
if ! which node >/dev/null; then
    log "Installing nodejs.."
    curl -sL https://rpm.nodesource.com/setup_10.x | bash -
    yum install -y nodejs
fi
if ! which gcc >/dev/null; then
    log "Installing C compiling tools.."
    yum --enablerepo=epel group install -y "Development Tools" >"$LOG"
fi
if ! which gmp-devel >/dev/null; then
    log "Installing gmp-devel.."
    yum --enablerepo=epel install -y gmp-devel >"$LOG"
fi

if ! which git >/dev/null; then
    log "Installing git.."
    yum install -y git >"$LOG"
fi

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
wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_21.1-1~centos~7_amd64.rpm
yum localinstall -y wxGTK-devel unixODBC-devel >"$LOG"
yum localinstall -y esl-erlang_21.1-1~centos~7_amd64.rpm >"$LOG"

log "Installing Elixir to /opt/elixir.."
mkdir -p /opt/elixir
wget https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip >"$LOG"
unzip Precompiled.zip -d /opt/elixir >"$LOG"
log "Elixir installed successfully!"

# Need to map the Parameter Store response to a set of NAME="<value>" entries,
# one per line, which will then be written to /etc/environment so that they are
# set for all users on the system
old_env="$(cat /etc/environment)"
{
    echo "$old_env"
    # shellcheck disable=SC2016
    echo 'PATH=/opt/elixir/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH'
    # shellcheck disable=SC1117
    echo "DYNO=\"$HOSTNAME\""
    echo "HOSTNAME=\"$HOSTNAME\""
    echo "LANG=en_US.UTF-8"
    echo "LANGUAGE=en_US"
    echo "LC_ALL=en_US.UTF-8"
    echo "LC_CTYPE=en_US.UTF-8"
} > /etc/environment

if ! which psql >/dev/null; then
    log "Installing psql.."
    amazon-linux-extras install postgresql10 >"$LOG"
fi

if ! which g++ >/dev/null; then
    log "Installing gcc-c++.."
    yum install -y gcc-c++ >"$LOG"
fi

log "Installing gcc for NIF compilation during code deploy"

yum install -y --enablerepo=epel gcc  >"$LOG"

log "Preinstalled software is ready!"

mkdir -p /opt >"$LOG" 

git clone https://github.com/poanetwork/blockscout -b ${BS_RELEASE} /opt/app

chown -R ec2-user /opt/app

exit 0
