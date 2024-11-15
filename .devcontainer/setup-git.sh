#!/bin/bash

git config --global credential.useHttpPath true
git config --get credential.useHttpPath
git remote -v

git config --global core.pager cat
git config --global user.email "devcontainer@strisys.com"
git config --global user.name "Stephen Trudel"