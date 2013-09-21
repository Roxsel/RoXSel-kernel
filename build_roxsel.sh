#/bin/bash

./build.sh cm 4.2.2 cwm clean
./build.sh cm 4.2.2 touch 
./build.sh cm 4.1.2 cwm
./build.sh cm 4.1.2 touch
./build.sh miui 4.1.2 cwm
./build.sh miui 4.1.2 touch
./build.sh stock 4.1.2 cwm
./build.sh stock 4.1.2 touch
