#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is intended to start the docker and then loop until
# it detects a failure.  It then exits, and supervisord restarts it
# which in turn restarts docker.

/etc/init.d/docker stop
# Make sure docker gracefully terminated before start again
while pidof docker > /dev/null; do
    echo "waiting clean shutdown"
    sleep 10
done

# cleanup docker network checkpoint to avoid running into known issue
# of docker (https://github.com/docker/docker/issues/18283)
rm -rf /var/lib/docker/network

/etc/init.d/docker start

echo "waiting two minute for startup"
sleep 120

while true; do
  if ! sudo timeout 20 docker ps > /dev/null; then
    echo "Docker failed!"
    exit 2
  fi
  sleep 10
done

