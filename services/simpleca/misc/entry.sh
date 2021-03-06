#!/bin/sh

trap "exit 0" SIGTERM

function wait_and_exit () {
  while [ "$(redis-cli -h redis get STRONGHOME_TEST_END)" != "READY" ]; do
    sleep 1
  done

  kill -s SIGTERM 1
}

echo "@strongHome@ - Starting SimpleCA"

chmod g+r /cert/radius-key.pem
adduser nginx root

spawn-fcgi -u nginx -s /run/fcgi.sock /usr/bin/fcgiwrap && nginx -g "daemon off;" &
MAIN_PROCESS=$!

if [[ $STRONGHOME_TEST ]]; then
  echo "@strongHome@ - Running tests"

  bats /test
  exit $?

fi


wait_and_exit &

wait $MAIN_PROCESS
