# README

## for xfs

```bash
sudo xfs_growfs /dev/vda1
sudo bash /usr/local/bin/setup-proxy.sh -l lab
sudo bash /usr/local/bin/setup-repo.sh -l jp
```

## Ubuntu 18.04 ext4

```bash
echo -e "Fix\n" | sudo parted ---pretend-input-tty /dev/vda -m print
size=$(sudo parted /dev/vda -m print | head -n 2 | tail -n 1 | cut -d ':' -f 2)
echo -e "Yes\n$size\n" | sudo parted ---pretend-input-tty /dev/vda resizepart 1
sudo resize2fs /dev/vda1
sudo bash /usr/local/bin/setup-proxy.sh -l lab
sudo bash /usr/local/bin/setup-repo.sh -l jp
```
