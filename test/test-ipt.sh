#!/bin/sh

function xtables() {
  ipt=$1
  chain=$2
  act=$3
  if [ "$act" = "append" ] ; then
    $ipt -N $chain
  fi
  $ipt --$act $chain -m dns --qr
  $ipt --$act $chain -m dns ! --qr
  $ipt --$act $chain -m dns --aa
  $ipt --$act $chain -m dns ! --aa
  $ipt --$act $chain -m dns --tc
  $ipt --$act $chain -m dns ! --tc
  $ipt --$act $chain -m dns --rd
  $ipt --$act $chain -m dns ! --rd
  $ipt --$act $chain -m dns --ra
  $ipt --$act $chain -m dns ! --ra
  $ipt --$act $chain -m dns --ad
  $ipt --$act $chain -m dns ! --ad
  $ipt --$act $chain -m dns --cd
  $ipt --$act $chain -m dns ! --cd
  $ipt --$act $chain -m dns --opcode QUERY
  $ipt --$act $chain -m dns ! --opcode QUERY
  $ipt --$act $chain -m dns --opcode UPDATE
  $ipt --$act $chain -m dns ! --opcode UPDATE
  $ipt --$act $chain -m dns --qname example.com
  $ipt --$act $chain -m dns ! --qname example.com
  $ipt --$act $chain -m dns --qtype A
  $ipt --$act $chain -m dns ! --qtype A
  $ipt --$act $chain -m dns --qtype AAAA
  $ipt --$act $chain -m dns ! --qtype AAAA
  $ipt --$act $chain -m dns --qtype MAILA
  $ipt --$act $chain -m dns ! --qtype MAILA
  $ipt --$act $chain -m dns --qtype ANY
  $ipt --$act $chain -m dns ! --qtype ANY
  $ipt --$act $chain -m dns --qtype URI
  $ipt --$act $chain -m dns ! --qtype URI
  $ipt --$act $chain -m dns --qtype TA
  $ipt --$act $chain -m dns ! --qtype TA
  $ipt --$act $chain -m dns --qname example.jp --rmatch
  $ipt --$act $chain -m dns ! --qname example.jp --rmatch
  $ipt --$act $chain -m dns --maxsize 128
  $ipt --$act $chain -m dns ! --maxsize 128
  if [ "$act" = "delete" ] ; then
    $ipt -X $chain
  fi
}

xtables $@
