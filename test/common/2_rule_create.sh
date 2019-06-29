#!/bin/bash

function ipt() {
  cmd=$1
  table=$2
  chain=$3
  act=$4
  ../util/test-ipt.sh $cmd $table $chain $act
}
function begin() {
  cmd=$1
  table=$2
  chain=$3
  act=$4
  ipt $cmd $table $chain "append"
}
function finish() {
  ipt $cmd $table $chain "delete"
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
  table=$2
  chain=$3
  begin $cmd $table $chain

  RULES=`$cmd -t $table --list-rules $chain -v`

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
  check "-m dns --qclass CH"
  check "-m dns ! --qclass CH"
  check "-m dns --qname example.jp --rmatch"
  check "-m dns ! --qname example.jp --rmatch"
  check "-m dns --maxsize 128"
  check "-m dns ! --maxsize 128"

  finish $cmd $table $chain
  
  echo "[PASS] $cmd $table add rules"
  return 0
}


main "iptables" filter $(date +DNSTEST-IPv4-%Y%m%d)
main "iptables" mangle $(date +DNSTEST-IPv4-%Y%m%d)

main "ip6tables" filter $(date +DNSTEST-IPv6-%Y%m%d)
main "ip6tables" mangle $(date +DNSTEST-IPv6-%Y%m%d)

exit 0
