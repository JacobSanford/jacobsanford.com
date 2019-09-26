#!/usr/bin/env bash
rm -rf docs
hugo -t hyde -d docs
echo -n "jacobsanford.com" > docs/CNAME

