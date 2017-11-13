set -eux

echo "==> Recording box generation date"
date > /etc/box_build_date
[ -f /etc/motd.origin ] || cp -pr /etc/motd /etc/motd.origin

echo "==> Customizing message of the day"
MOTD_FILE=/etc/motd
BANNER_WIDTH=64
PLATFORM_RELEASE=$(cat /etc/alpine-release)
PLATFORM_MSG=$(printf '%s' "Alpine $PLATFORM_RELEASE")
BUILT_MSG=$(printf 'built %s' $(date +%Y-%m-%d))
bash -c "printf '%0.1s' '-'{1..64} > ${MOTD_FILE}"
bash -c "printf '\n' >> ${MOTD_FILE}"
bash -c "printf '%2s%-30s%30s\n' \" \" \"${PLATFORM_MSG}\" \"${BUILT_MSG}\" >> ${MOTD_FILE}"
bash -c "printf '%0.1s' '-'{1..64} >> ${MOTD_FILE}"
bash -c "printf '\n' >> ${MOTD_FILE}"
