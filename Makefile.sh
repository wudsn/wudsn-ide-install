#!/bin/bash
# Makefile for Linux and macOS

NAME=wudsn
IN_FILE=${NAME}.sh
OUT_FILE=${NAME}.tar.gz
chmod a+x "${IN_FILE}"
tar zcfv "${OUT_FILE}" "${IN_FILE}"
echo Archive ${OUT_FILE} created.
