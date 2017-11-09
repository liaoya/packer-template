#!/bin/bash -eux

echo "==> Recording box generation date"
date > /etc/box_build_date

echo "==> Customizing message of the day"
MOTD_FILE=/etc/motd
BANNER_WIDTH=64
PLATFORM_RELEASE=$(lsb_release -sd)
if [[ -n $VM_NAME && $(lsb_release -cs) != $VM_NAME ]]
    PLATFORM_MSG=$(printf '%s (On %s)' "$VM_NAME" "$PLATFORM_RELEASE")
else
    PLATFORM_MSG=$(printf '%s' "$PLATFORM_RELEASE")
fi
BUILT_MSG=$(printf 'built %s' $(date +%Y-%m-%d))
printf '%0.1s' "-"{1..64} > ${MOTD_FILE}
printf '\n' >> ${MOTD_FILE}
printf '%2s%-40s%20s\n' " " "${PLATFORM_MSG}" "${BUILT_MSG}" >> ${MOTD_FILE}
printf '%0.1s' "-"{1..64} >> ${MOTD_FILE}
printf '\n' >> ${MOTD_FILE}
