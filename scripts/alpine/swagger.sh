set -eux

[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh
apk add nodejs-npm
npm install -g -g http-server
mkdir -p /opt/swagger
curl -L https://github.com/swagger-api/swagger-editor/archive/v3.0.15.tar.gz | tar -C /opt/swagger -xz