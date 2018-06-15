#!/bin/bash -eux

echo "==> Enhance sshd"

grep -s -q -w "UseDNS yes" /etc/ssh/sshd_config && sed -i "/UseDNS/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i UseDNS no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPIAuthentication yes" /etc/ssh/sshd_config && sed -i "/GSSAPIAuthentication/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPIAuthentication no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPICleanupCredentials yes" /etc/ssh/sshd_config && sed -i "/GSSAPICleanupCredentials/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPICleanupCredentials no" /etc/ssh/sshd_config
