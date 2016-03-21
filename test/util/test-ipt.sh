#!/bin/bash

function xtables() {
  ipt=$1
  table=$2
  chain=$3
  act=$4
  if [ "$act" = "append" ] ; then
    $ipt -t $table -N $chain
  fi
  $ipt -t $table --$act $chain -m dns --qr
  $ipt -t $table --$act $chain -m dns ! --qr
  $ipt -t $table --$act $chain -m dns --aa
  $ipt -t $table --$act $chain -m dns ! --aa
  $ipt -t $table --$act $chain -m dns --tc
  $ipt -t $table --$act $chain -m dns ! --tc
  $ipt -t $table --$act $chain -m dns --rd
  $ipt -t $table --$act $chain -m dns ! --rd
  $ipt -t $table --$act $chain -m dns --ra
  $ipt -t $table --$act $chain -m dns ! --ra
  $ipt -t $table --$act $chain -m dns --ad
  $ipt -t $table --$act $chain -m dns ! --ad
  $ipt -t $table --$act $chain -m dns --cd
  $ipt -t $table --$act $chain -m dns ! --cd
  $ipt -t $table --$act $chain -m dns --opcode QUERY
  $ipt -t $table --$act $chain -m dns ! --opcode QUERY
  $ipt -t $table --$act $chain -m dns --opcode UPDATE
  $ipt -t $table --$act $chain -m dns ! --opcode UPDATE
  $ipt -t $table --$act $chain -m dns --qname example.com
  $ipt -t $table --$act $chain -m dns ! --qname example.com
  $ipt -t $table --$act $chain -m dns --qtype A
  $ipt -t $table --$act $chain -m dns ! --qtype A
  $ipt -t $table --$act $chain -m dns --qtype AAAA
  $ipt -t $table --$act $chain -m dns ! --qtype AAAA
  $ipt -t $table --$act $chain -m dns --qtype MAILA
  $ipt -t $table --$act $chain -m dns ! --qtype MAILA
  $ipt -t $table --$act $chain -m dns --qtype ANY
  $ipt -t $table --$act $chain -m dns ! --qtype ANY
  $ipt -t $table --$act $chain -m dns --qtype URI
  $ipt -t $table --$act $chain -m dns ! --qtype URI
  $ipt -t $table --$act $chain -m dns --qtype TA
  $ipt -t $table --$act $chain -m dns ! --qtype TA
  $ipt -t $table --$act $chain -m dns --qname example.jp --rmatch
  $ipt -t $table --$act $chain -m dns ! --qname example.jp --rmatch
  $ipt -t $table --$act $chain -m dns --maxsize 128
  $ipt -t $table --$act $chain -m dns ! --maxsize 128
  if [ "$act" = "delete" ] ; then
    $ipt -t $table -X $chain
  fi
}

xtables $@
