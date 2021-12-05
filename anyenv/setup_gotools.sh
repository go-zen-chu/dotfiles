#!/usr/bin/env bash

GO_VERSION="1.17.2"
goenv install $GO_VERSION
goenv global $GO_VERSION

# test tools
go install github.com/golang/mock/gomock
go install github.com/cweill/gotests/...

# dev tool
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
