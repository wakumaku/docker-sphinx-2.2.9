#!/bin/bash

indexer --all "$@" && searchd --nodetach "$@"
