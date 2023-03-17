#!/bin/bash
# Makefile for Linux and macOS

NAME=wudsn
IN_FILE=${NAME}.sh
OUT_FILE=${NAME}.tar.gz
chmod a+x "${IN_FILE}"
tar zcfv "${OUT_FILE}" "${IN_FILE}"
echo Archive ${OUT_FILE} for Linux created.

APP_FOLDER_NAME=${NAME}.app
APP_FOLDER=out/${APP_FOLDER_NAME}
OUT_FILE=${APP_FOLDER_NAME}.tar.gz
rm -rf "${APP_FOLDER}"
mkdir "${APP_FOLDER}"
cp "${IN_FILE}" "${APP_FOLDER}/"
tar zcfv "${OUT_FILE}" "${APP_FOLDER}"
echo Archive ${OUT_FILE} for macOS created.
