#!/bin/bash

ls -1 results/*fps*|grep -v multi | grep -v png|grep 19kb|while read p; do
  echo -n `basename $p .json`;
  node read_fps $p;
done
