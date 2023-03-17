#!/bin/bash
# Makefile for Linux and macOS

set -e

NAME=wudsn

IN_FILE=${NAME}.sh
OUT_FILE=${NAME}.tar.gz
chmod a+x "${IN_FILE}"
tar zcfv "${OUT_FILE}" "${IN_FILE}"
echo Archive ${OUT_FILE} for Linux created.

cp "${IN_FILE}" "${NAME}.command"
IN_FILE=${NAME}.command
OUT_FILE=${IN_FILE}.tar.gz
tar zcfv "${OUT_FILE}" "${IN_FILE}"
echo Archive ${OUT_FILE} for macOS created.

APP_FOLDER_NAME=${NAME}.app
CONTENTS_FOLDER=out/${APP_FOLDER_NAME}/Contents
SCRIPT_FOLDER=${CONTENTS_FOLDER}/MacOS
OUT_FILE=${APP_FOLDER_NAME}.tar.gz
rm -rf "${SCRIPT_FOLDER}"
mkdir -p "${SCRIPT_FOLDER}"
cp "build/Info.plist" "${CONTENTS_FOLDER}/"
cp "${IN_FILE}" "${SCRIPT_FOLDER}/"
cd "out"
tar zcfv "../${OUT_FILE}" "${APP_FOLDER_NAME}"
cd ..
echo Archive ${OUT_FILE} for macOS created.
