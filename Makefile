#!/usr/bin/make -f

# COMMIT := $(shell git log -1 --format='%H')
NETWORK_TYPE := bfbnet

export GO111MODULE = on
export GOPROXY = https://goproxy.cn
# windows, linux, darwin
export GOOS = windows
export GOARCH = amd64

# include ledger support
include Makefile.ledger

ldflags = -X 'go-bfb/version.NetworkType=$(NETWORK_TYPE)' \
          -X 'go-bfb/version.BuildTags=netgo'

BUILD_FLAGS := -tags "$(build_tags)" -ldflags "$(ldflags)"

all: build

build: go.sum
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/bfbd.exe ./cmd/bfbd
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/bfbcli.exe ./cmd/bfbcli
else
    UNAME_S := $(shell uname -s)
    goos_flag := linux
    ifeq ($(UNAME_S), Darwin)
        goos_flag = darwin
    endif
    ifeq ($(UNAME_S), OpenBSD)
        goos_flag = openbsd
    endif
    ifeq ($(UNAME_S), FreeBSD)
        goos_flag = freebsd
    endif
    ifeq ($(UNAME_S), NetBSD)
        goos_flag = netbsd
    endif
	GOOS=$(goos_flag) GOARCH=amd64 go build -mod=readonly $(BUILD_FLAGS) -o build/$(goos_flag)/bfbd ./cmd/bfbd
	GOOS=$(goos_flag) GOARCH=amd64 go build -mod=readonly $(BUILD_FLAGS) -o build/$(goos_flag)/bfbcli ./cmd/bfbcli
endif

build-windows: go.sum
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/bfbd.exe ./cmd/bfbd
	go build -mod=readonly $(BUILD_FLAGS) -o build/windows/bfbcli.exe ./cmd/bfbcli

build-linux: go.sum
# LEDGER_ENABLED=false GOOS=linux GOARCH=amd64 $(MAKE) build
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/linux/bfbd ./cmd/bfbd
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/linux/bfbcli ./cmd/bfbcli

build-mac: go.sum
# LEDGER_ENABLED=false GOOS=darwin GOARCH=amd64 $(MAKE) build
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/mac/bfbd ./cmd/bfbd
	go build -mod=readonly -tags "netgo" -ldflags "$(ldflags)" -o build/mac/bfbcli ./cmd/bfbcli

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download

go.sum: go.mod
	@echo "--> Ensure dependecies have not been modified"
	@go mod verify
	@go mod tidy

clean:
	rm -rf build/

