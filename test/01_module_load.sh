#!/bin/sh


iptables -m dns --help > /dev/null 2>&1
if [ $? != 0 ] ; then
  echo "[ERR] iptables load error libxt_dns.so."
  exit 1
fi
echo "[PASS] iptables load check"
ip6tables -m dns --help > /dev/null 2>&1
if [ $? != 0 ] ; then
  echo "[ERR] ip6tables load error libxt_dns.so."
  exit 1
fi
echo "[PASS] ip6tables load check"

exit 0
