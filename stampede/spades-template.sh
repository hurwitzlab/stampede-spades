#!/bin/bash

set -u

WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

DEBUG=''
if [[ -n ${VERBOSE:-''} ]]; then
  DEBUG='--debug'
fi

SC_ARG=""
if [[ ${SC:-''} == "yes" ]]; then
  SC_ARG='--sc'
fi

META_ARG=""
if [[ ${META:-''} == "yes" ]]; then
  META_ARG='--meta'
fi

IONTORRENT_ARG=""
if [[ ${IONTORRENT:-''} == "yes" ]]; then
  IONTORRENT_ARG='--iontorrent'
fi

K_ARG=""
if [[ ${#K} -gt 1 ]]; then
  K_ARG="-k $K"
fi

FILE_DESC_ARG=""
if [[ ${#FILE_DESC} -gt 1 ]]; then
  FILE_DESC_ARG="-f $FILE_DESC"
fi

$WRAPPERDIR/run-spades.pl -d ${IN_DIR} -o ${OUT_DIR:-"${WRAPPERDIR}/spades-out"} -c ${COV_CUTOFF:-"off"} -p ${PHRED_OFFSET:-0} $SC_ARG $META_ARG $IONTORRENT_ARG $K_ARG $FILE_DESC_ARG $DEBUG
