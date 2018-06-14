#!/usr/bin/env bash
$DIR="/var/lib/vimsg/"
mkdir -p ${DIR}{nugget,deleted}
chown -R $USER $DIR
pp -o nugget nugget.pl
install nugget /usr/local/bin/
nugget
