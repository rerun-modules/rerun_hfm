#!/usr/bin/env roundup
#
# Baselib test
#/ usage: rerun stubbs:test -m MODULE -p baselib
#
# Author: Ines Neubach <ines.neubach@idn.astzweig.de>
#

# Include baselib file
# -----------------
MODULE="$(basename $(cd ..; pwd))";
BASELIB_PATH="${RERUN_MODULES}/${MODULE}/lib/baselib.sh";
if [ ! -f ${BASELIB_PATH} ]; then
    exit;
fi

source ${BASELIB_PATH};

# The Plan
# --------

describe "baselib - createDirIfNotExists"

it_stops_with_no_arguments() {
  local RETV;
  RETV="$(createDirIfNotExists && echo $? || echo $?)";
  test ${RETV} -eq 10;
}

it_stops_with_dir_already_existing() {
  local RETV TMPD="$(pwd)/.${MODULE}1.$$";
  [ ! -d "${TMPD}" ] && mkdir ${TMPD};
  trap "rm -rf \"${TMPD}\"" EXIT INT;
  RETV="$(createDirIfNotExists ${TMPD} && echo $? || echo $?)";
  test ${RETV} -eq 20;
}

it_stops_with_user_answer_being_not_yes() {
  local RETV TMPD="$(pwd)/.${MODULE}3.$$";
  test ! -d ${TMPD};
  RETV="$(createDirIfNotExists ${TMPD} <<< "n" && echo $? || echo $?)";
  test ${RETV} -eq 40;
  test ! -d ${TMPD};
}

it_stops_with_mkdir_not_working() {
  local RETV TMPD="$(pwd)/.${MODULE}4.$$" TESTDIR="${TMPD}/somedir";
  [ ! -d "${TMPD}" ] && mkdir ${TMPD};
  trap "rm -rf \"${TMPD}\"" EXIT INT;
  chmod a-w ${TMPD};
  RETV="$(createDirIfNotExists ${TESTDIR} <<< "y" && echo $? || echo $?)";
  test ${RETV} -eq 30;
  test ! -d ${TESTDIR};
}

it_works_with_user_answer_being_y_or_yes() {
  local RETV TMPD="$(pwd)/.${MODULE}5.$$";
  trap "rm -rf \"${TMPD}\"" EXIT INT;
  RETV="$(createDirIfNotExists ${TMPD} <<< "yes" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -d ${TMPD};
  rm -rf ${TMPD};
  RETV="$(createDirIfNotExists ${TMPD} <<< "y" && echo $? || echo $?)";
  test ${RETV} -eq 0;
  test -d ${TMPD};
}