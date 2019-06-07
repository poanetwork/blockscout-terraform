#!/usr/bin/env bash

#ELIXIR_VERSION and BS_RELEASE should be defined as environment variables
set -e -x

LOG=/var/log/user_data.log

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
    yum --enablerepo=epel install -y nodejs >"$LOG"
fi
if ! which gcc >/dev/null; then
    log "Installing C compiling tools.."
    yum --enablerepo=epel group install -y "Development Tools" >"$LOG"
fi
if ! which gmp-devel >/dev/null; then
    log "Installing gmp-devel.."
    yum --enablerepo=epel install -y gmp-devel >"$LOG"
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
wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_21.1-1~centos~7_amd64.rpm
yum localinstall -y wxGTK-devel unixODBC-devel >"$LOG"
yum localinstall -y esl-erlang_21.1-1~centos~7_amd64.rpm >"$LOG"

log "Installing Elixir to /opt/elixir.."
mkdir -p /opt/elixir
wget https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip >"$LOG"
unzip Precompiled.zip -d /opt/elixir >"$LOG"
log "Elixir installed successfully!"

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

log "Starting CodeDeploy agent.."
service codedeploy-agent start >"$LOG"

mkdir /opt > /dev/null

git clone https://github.com/poanetwork/blockscout -b ${BS_RELEASE} /opt/app

/opt/app/bin/deployment/stop
/opt/app/bin/deployment/build
/opt/app/bin/deployment/migrate

mkdir -p /opt/app
chown -R ec2-user /opt/app

exit 0
