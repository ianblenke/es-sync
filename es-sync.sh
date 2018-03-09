#!/bin/bash

set -eo pipefail

[ -n "$SRC_USER" ]
[ -n "$SRC_URL" ]
[ -n "$SRC_INCLUDE_FILTER" ]
[ -n "$SRC_EXCLUDE_FILTER" ]
[ -n "$DST_USER" ]
[ -n "$DST_URL" ]
[ -n "$SLEEP" ]
[ -n "$DST_PASS" ]
[ -n "$SRC_PASS" ]

while true; do

  echo "Pulling indexes from source"

  INDEXES="$(curl -u ${SRC_USER}:${SRC_PASS} -XGET -sL ${SRC_URL}'/_cat/indices?h=index,store.size&bytes=k&format=json' | jq -r .[].index | sort -r | grep $SRC_INCLUDE_FILTER | grep -v $SRC_EXCLUDE_FILTER )"

  echo "Indexes: ${INDEXES}"

  for index in $INDEXES ; do

    echo "$SRC_URL/$index "
    curl -u ${DST_USER}:${DST_PASS} -sL -H "Content-Type: application/json" -XPOST $DST_URL/_reindex --data-binary @- <<EOF
{
  "source": {
    "remote": {
      "host": "${SRC_URL}",
      "username": "${SRC_USER}",
      "password": "${SRC_PASS}",
      "socket_timeout": "1m",
      "connect_timeout": "10s"
    },
    "index": "$index",
    "query": {
      "match_all": {}
    }
  },
  "dest": {
    "index": "$index"
  }
}
EOF
    echo ""

  done

  echo "Sleeping for $SLEEP seconds"
  sleep $SLEEP

done
