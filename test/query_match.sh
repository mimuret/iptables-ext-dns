#!/bin/bash

IPT=$1
PROTOCOL=$2
TABLE=$3

. query_match_common.sh

if [ "$TABLE" = "filter" ] ; then
  TARGET_CHAIN="INPUT"
fi
if [ "$TABLE" = "mangle" ] ; then
  TARGET_CHAIN="PREROUTING"
fi

function match_check() {
  val=$1
  if [ "$val" != "0" ] ; then
    return 1
  fi
  return 0
}

function main() {
  begin

  T="example.net"
  BITFLAGS="-o qr -o aa -o tc -o rd -o ra -o  cd -o ra -o ad"
  check "-m dns --qr" "$T" $(echo $BITFLAGS | sed 's/qr/QR/g')
  check "-m dns ! --qr" "$T" $BITFLAGS
  check "-m dns --aa" "$T" $(echo $BITFLAGS | sed 's/aa/AA/g')
  check "-m dns ! --aa" "$T" $BITFLAGS
  check "-m dns --tc" "$T" $(echo $BITFLAGS | sed 's/tc/TC/g')
  check "-m dns ! --tc" "$T" $BITFLAGS
  check "-m dns --rd" "$T" $(echo $BITFLAGS | sed 's/rd/RD/g')
  check "-m dns ! --rd" "$T" $BITFLAGS
  check "-m dns --ra" "$T" $(echo $BITFLAGS | sed 's/ra/RA/g')
  check "-m dns ! --ra" "$T" $BITFLAGS
  check "-m dns --ad" "$T" $(echo $BITFLAGS | sed 's/ad/AD/g')
  check "-m dns ! --ad" "$T" $BITFLAGS
  check "-m dns --cd" "$T" $(echo $BITFLAGS | sed 's/cd/CD/g')
  check "-m dns ! --cd" "$T" $BITFLAGS

  check "-m dns --opcode QUERY" "$T"
  updateCheck "-m dns ! --opcode QUERY"
  updateCheck "-m dns --opcode UPDATE"
  check "-m dns ! --opcode UPDATE" "$T"

  check "-m dns --qname example.com" "example.com"
  check "-m dns ! --qname example.com" "com"
  check "-m dns ! --qname example.com" "www.example.com"

  check "-m dns --qtype A" "example.net" "TYPE1"
  check "-m dns ! --qtype A" "example.net" "TYPE6"
  check "-m dns --qtype AAAA" "example.net" "TYPE28"
  check "-m dns ! --qtype AAAA" "example.net" "TYPE2"
  check "-m dns --qtype MAILA" "example.net" "TYPE254"
  check "-m dns ! --qtype MAILA" "example.net" "TYPE16"
  check "-m dns --qtype ANY" "example.net" "TYPE255"
  check "-m dns ! --qtype ANY" "example.net" "TYPE52"
  check "-m dns --qtype URI" "example.net" "TYPE256"
  check "-m dns ! --qtype URI" "example.net" "TYPE15"
  check "-m dns --qtype TA" "example.net" "TYPE32768"
  check "-m dns ! --qtype TA" "example.net" "TYPE32769"

  check "-m dns --qname example.jp --rmatch" "example.jp"
  check "-m dns --qname example.jp --rmatch" "www.example.jp"
  check "-m dns ! --qname example.jp --rmatch" "example.net"
  check "-m dns --maxsize 128"  "lQZaMll8woJoxWsSzDA4vxUr8wcWW1AcG2KVPJvQTbC3B6DSJadwGDqUJHpgNwj.4f7JIOUYK2sQAAcUDCXsTH0WvzkSdxWsD1kflPYwMjdbKCeRl6.example.com."
  check "-m dns ! --maxsize 128"  "lQZaMll8woJoxWsSzDA4vxUr8wcWW1AcG2KVPJvQTbC3B6DSJadwGDqUJHpgNwj.4f7JIOUYK2sQAAcUDCXsTH0WvzkSdxWsD1kflPYwMjfdbKCeRl6.example.com."

  finish
}

main

exit 0
