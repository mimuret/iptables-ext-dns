#!/bin/sh

function ipt() {
  cmd=$1
  chain=$2
  act=$3
  ./test-ipt.sh $cmd $chain $act
}
function begin() {
  cmd=$1
  chain=$2
  ipt $cmd $chain "append"
}
function finish() {
  ipt $cmd $chain "delete"
}
function error() {
  echo "[ERR] $@"
  finish
  exit 1
}

function check() {
  rule=$(echo "$1" | sed 's/-/\\-/g')
  echo "$RULES" | grep -q "$rule " || error $1
}
function main() {
  cmd=$1
  chain=$2
  begin $cmd $chain

  RULES=`$cmd --list-rules $chain -v`

  check "-m dns --qr"
  check "-m dns ! --qr"
  check "-m dns --aa"
  check "-m dns ! --aa"
  check "-m dns --tc"
  check "-m dns ! --tc"
  check "-m dns --rd"
  check "-m dns ! --rd"
  check "-m dns --ra"
  check "-m dns ! --ra"
  check "-m dns --ad"
  check "-m dns ! --ad"
  check "-m dns --cd"
  check "-m dns ! --cd"
  check "-m dns --opcode QUERY"
  check "-m dns ! --opcode QUERY"
  check "-m dns --opcode UPDATE"
  check "-m dns ! --opcode UPDATE"
  check "-m dns --qname example.com"
  check "-m dns ! --qname example.com"
  check "-m dns --qtype A"
  check "-m dns ! --qtype A"
  check "-m dns --qtype AAAA"
  check "-m dns ! --qtype AAAA"
  check "-m dns --qtype MAILA"
  check "-m dns ! --qtype MAILA"
  check "-m dns --qtype ANY"
  check "-m dns ! --qtype ANY"
  check "-m dns --qtype URI"
  check "-m dns ! --qtype URI"
  check "-m dns --qtype TA"
  check "-m dns ! --qtype TA"
  check "-m dns --qname example.jp --rmatch"
  check "-m dns ! --qname example.jp --rmatch"
  check "-m dns --maxsize 128"
  check "-m dns ! --maxsize 128"

  finish $cmd $chain
  
  echo "[PASS] $cmd add rules"
  return 0
}


main "iptables" $(date +DNSTEST-IPv4-%Y%m%d)

main "ip6tables" $(date +DNSTEST-IPv6-%Y%m%d)

exit 0
