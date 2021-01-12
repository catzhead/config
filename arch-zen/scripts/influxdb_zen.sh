#!/bin/sh
curl --cacert stats-catzhead-xyz.pem 'https://stats.catzhead.xyz/influxdb/query?pretty=true&u=<USER>&p=<PASSWORD>' --data-urlencode 'db=zen_telegraf' --data-urlencode 'q=SELECT "*" FROM "*"'
