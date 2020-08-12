#!/bin/bash -e

on_chroot << EOF
echo "${DOCKER_REPO_PASS}" | docker login -u ${DOCKER_REPO_USER}
EOF
