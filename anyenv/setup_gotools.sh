#!/usr/bin/env bash

cd "${HOME}/.anyenv/envs/goenv/plugins/go-build/../.." && git pull && cd -

GO_VERSION="1.23.2"
goenv install $GO_VERSION
goenv global $GO_VERSION

# test tools
go install github.com/golang/mock/gomock
go install github.com/cweill/gotests/...

# dev tool
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
