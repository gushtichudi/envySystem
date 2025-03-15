#!/bin/bash

info() {
  printf "\e[34m[ info ]\e[0m:: $1\n"
}

success() {
  printf "\e[32m[  ok  ]\e[0m:: $1\n"
}

warn() {
  printf "\e[33m[ warn ]\e[0m:: $1\n"
}

error() {
  printf "\e[31m[ FAIL ]\e[0m:: $1\n"

  if [[ $2 == "yes" ]]; then
    printf "Aborting immediately.\n"
    exit 1
  fi
}
