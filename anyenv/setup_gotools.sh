#!/usr/bin/env bash

# test tools
go get -u github.com/golang/mock/gomock
go get -u github.com/cweill/gotests/...

# dev tool
go get golang.org/x/tools/gopls@latest
go get -u github.com/krishicks/minio/mc
