#!/bin/sh

IPT=$1
PROTOCOL=$2
if [ "$IPT" = 'iptables' ] ; then
  SERVER='127.0.0.1'
else
  SERVER='::1'
fi
if [ "$PROTOCOL" = "udp" ] ; then
  NSUPDATE_OPT=
  DRILL_OPT='-u'
else
  NSUPDATE_OPT='-v'
  DRILL_OPT='-t'
fi

DNSTEST=$(date +DNSTEST-%Y%m%d)

function ipt() {
  ./test-ipt.sh $IPT $DNSTEST $1
}
function begin() {
  ipt "append"
  if [ "$PROTOCOL" = "udp" ] ; then
    $IPT -I INPUT -i lo -p udp --dport 53 -j $DNSTEST
  else
    $IPT -I INPUT -i lo -p tcp --dport 53 -j $DNSTEST
  fi
}
function finish() {
  if [ "$PROTOCOL" = "udp" ] ; then
    $IPT -D INPUT -i lo -p udp --dport 53 -j $DNSTEST
  else
    $IPT -D INPUT -i lo -p tcp --dport 53 -j $DNSTEST
  fi
  ipt "delete"
}
function error() {
  echo "[FAIL] $@"
  $IPT --list-rules $DNSTEST -v
  finish
  exit 1
}
function updateCheck() {
  rule=$(echo "$1" | sed 's/-/\\-/g')
  $IPT --zero $DNSTEST

  echo "server $SERVER
prereq yxdomain example.org
update add www.example.org 3600 A 127.0.0.1
send " | nsupdate $NSUPDATE_OPT > /dev/null 2>&1
  res=$($IPT --list-rules $DNSTEST -v | grep "$rule")
  if [ $? != 0 ] ; then
    error $@
  fi
  val=$(echo $res | awk '{print $NF}' )
  if [ "$val" = "0" ] ; then
    error $@
  fi
  echo "[PASS] $1"
}
function check() {
  _rule=$1
  rule=$(echo "$1" | sed 's/-/\\-/g') ; shift
  domain=$1 ; shift
  $IPT --zero $DNSTEST
  drill $domain @$SERVER $DRILL_OPT $@ > /dev/null 2>&1
  res=$($IPT --list-rules $DNSTEST -v | grep "$rule ")
  if [ $? != 0 ] ; then
    error $_rule $domain $@
  fi
  
  val=$(echo $res | awk '{print $NF}' )
  if [ "$val" = "0" ] ; then
    error $_rule $domain $@
  fi
  echo "[PASS] $_rule"
}

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

exit 0
