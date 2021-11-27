#!/bin/bash

# Run Apache Benchmark and execute N queries (given
# as the first argument), where N defaults to 100
docker run --net internal --rm jordi/ab -k -c 100 -n ${1:-100} http://172.16.0.5:8080/
