#/bin/bash

./build.sh cm 4.2.2 touch clean
./build.sh cm 4.2.2 default
./build.sh cm 4.1.2 touch
./build.sh cm 4.1.2 default
./build.sh miui 4.1.2 default
./build.sh miui 4.1.2 touch
./build.sh stock 4.1.2 default
./build.sh stock 4.1.2 touch
