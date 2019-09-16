#!/usr/bin/env bash

go get -u github.com/golang/mock/gomock
# test tools
go get -u github.com/onsi/ginkgo/ginkgo
go get -u github.com/onsi/gomega/...

# dev tool
go get -u github.com/pivotal-cf/om
go get -u github.com/krishicks/yaml-patch/cmd/yaml-patch
go get -u github.com/krishicks/minio/mc
