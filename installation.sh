#!/usr/bin/env bash
$DIR="/var/lib/vimsg/"
$NUGGET_DIR="${DIR}nugget"
$DELETED_DIR="${DIR}deleted"
sudo mkdir -p $NUGGET_DIR 2>/dev/null
sudo mkdir -p $DELETED_DIR 2>/dev/null
sudo chown -R $USER $DIR
pp -o nugget nugget.pl
sudo install nugget /usr/local/bin/
echo "application successfully installed"
nugget
