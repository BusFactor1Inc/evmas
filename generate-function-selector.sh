#!/bin/sh

echo $(node index.js "${1-'usage: $0 <function declaration>'}" | cut -b1-10)