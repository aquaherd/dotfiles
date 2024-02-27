#!/bin/sh
yum -y upgrade
yum -y autoremove
yum -y clean all

