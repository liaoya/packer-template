#!/bin/bash -eux

echo "==> Run custom Java script"

echo "==> Install Jabba"
export JABBA_HOME=/opt/jabba
[ -d $JABBA_HOME ] && rm -fr $JABBA_HOME
curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash
chown -R "$(id -u):$(id -g)" $JABBA_HOME

echo "==> Install sdkman"
export SDKMAN_DIR=/opt/sdkman
[[ $(command -v) unzip || $(command -v) zip ]] || { echo "unzip is required"; exit 0 }
[ -d $SDKMAN_DIR ] && rm -fr $SDKMAN_DIR
curl -sL "https://get.sdkman.io" | bash
chown -R "$(id -u):$(id -g)" $SDKMAN_DIR

sed -i "/jabba.sh/d" ~/.bashrc
sed -i "/sdkman/Id" ~/.bashrc

cat << 'EOF' > /etc/profile.d/sdkman.sh
export SDKMAN_DIR="/opt/sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF

cat << 'EOF'> /etc/profile.d/jabba.sh
export JABBA_HOME=/opt/jabba
[ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"
EOF
