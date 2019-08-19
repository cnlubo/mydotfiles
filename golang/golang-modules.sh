#!/bin/bash
### 
# @Author: cnak47
 # @Date: 2019-08-19 12:54:13
 # @LastEditors: cnak47
 # @LastEditTime: 2019-08-19 12:57:43
 # @Description: 
 ###

 echo ""
echo "===================================================================="
echo " Install golang modules ......"
echo " You may need a proxy ....."
echo "====================================================================="
echo ""
echo ""
gvm pkgset use global
go get -u golang.org/x/lint/golint
go get -u golang.org/x/tools/cmd/goimports
go get -u github.com/nsf/gocode
go get -u github.com/rogpeppe/godef
go get -u github.com/zmb3/gogetdoc
go get -u github.com/go-delve/delve/cmd/dlv
go get -u github.com/mitchellh/gox

