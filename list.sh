#!/bin/bash

# list all dris recrusive and count it
ls -lR | grep ^d | awk '{print $9}' | wc -l

# list all files and dirs recrusive and count it
ls -lR | wc -l
