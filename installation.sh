#!/usr/bin/env bash
$DIR="/var/lib/vimsg/"
$NUGGET_DIR="${DIR}nugget"
sudo mkdir -p $NUGGET_DIR 2>/dev/null
sudo chown -R $USER $DIR
chmod u+x ./nugget.pl
sudo mv ./nugget.pl /usr/local/bin/nugget
echo "nugget successfully installed"
nugget
