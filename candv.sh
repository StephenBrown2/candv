#!/bin/bash
# Name: Chapter and Verse script.
# Purpose: Given two numbers A and B, print all Bible verses matching A:B Chapter and Verse set, using the NET Bible API.
# Dependencies: jq (https://stedolan.github.io/jq/), and recode (https://www.gnu.org/software/recode/), both of which should be available in your repositories, though will need EPEL repo for jq on CentOS
# Author: Stephen Brown II
# Date: 2014-10-06

DEBUG=0;
ch="$1";
vs="$2";

# Biblical Books (not including Apocrypha/Deuterocanonicals)
# From: http://people.ucalgary.ca/~eslinger/genrels/SBLStandAbbrevs.html
sblbks='Gen Ex Lev Num Deut Josh Judg Ruth 1Sam 2Sam 1Kgs 2Kgs 1Chr 2Chr Ezra Neh Esth Job Ps Prov Eccl Song Isa Jer Lam Ezek Dan Hos Joel Amos Oba Jonah Mic Nah Hab Zeph Hag Zech Mal Mt Mk Lk Jn Acts Rom 1Cor 2Cor Gal Eph Phil Col 1Thes 2Thes 1Tim 2Tim Tit Phm Heb Jas 1Pet 2Pet 1Jn 2Jn 3Jn Jude Rev'

netcpyrt='\nScripture quoted by permission.\nAll scripture quotations, unless otherwise indicated, are taken from the NET Bible® copyright ©1996-2006 by Biblical Studies Press, L.L.C. All rights reserved.'

function debug {
  level=$1;
  shift;
  if (( $level <= $DEBUG )); then
    echo "DEBUG $level: $@" > /dev/stderr;
  fi;
}

function getv {
  base_url='http://labs.bible.org/api/?passage=';
  format='formatting=plain';
  type='type=json'
  if (( $# == 1)); then
    PASSAGE=0;
    passage=$1;
    get="${base_url}${passage}&${format}&${type}";
  elif (( $# == 3 )); then
    PASSAGE=1;
    bk=$1;
    ch=$2;
    vs=$3;
    get="${base_url}${bk}%20${ch}:${vs}&${format}&${type}";
  else
    debug 1 "Wrong number of arguments passed to getv ($#): should be 1 or 3";
  fi;
  debug 3 get $get;
  result=$(curl -s "${get}");
  debug 3 result $result;
  entries=$(echo "$result" | jq '. | length');
  debug 3 entries $entries;
  if (( $entries > 1 )); then
    # TODO: Properly re-join multiple verses
    debug 1 "Too many entries at the moment. Just using the first.";
  fi;
  rbk=$(echo "$result" | jq '.[0].bookname' | tr -d '"');
  debug 2 rbk $rbk;
  rch=$(echo "$result" | jq '.[0].chapter' | tr -d '"');
  debug 2 rch $rch;
  rvs=$(echo "$result" | jq '.[0].verse' | tr -d '"');
  debug 2 rvs $rvs;
  txt=$(echo "$result" | jq '.[0].text' | tr -d '"' | sed -e "s/[‘’]/'/g" -e 's/[“”]/"/g' | recode h/..);
  debug 3 txt $txt;
  if (( $PASSAGE == 1 )); then
    if exists $ch $vs $rch $rvs; then
      echo "${rbk} ${rch}:${rvs} - ${txt}";
    fi;
  else
    echo "${rbk} ${rch}:${rvs} - ${txt}";
  fi;
}

function exists {
  ch=$1;
  vs=$2;
  rch=$3;
  rvs=$4;
  if [[ $ch == $rch ]] && [[ $vs == $rvs ]]; then
    debug 1 "Both returned Chapter and Verse match the request"
    return 0;
  elif [[ $ch != $rch ]] && [[ $vs == $rvs ]]; then
    debug 1 "Returned Chapter does not match, but Verse does"
    return 1;
  elif [[ $ch == $rch ]] && [[ $vs != $rvs ]]; then
    debug 1 "Returned Chapter matches, but Verse does not"
    return 2;
  elif [[ $ch != $rch ]] && [[ $vs != $rvs ]]; then
    debug 1 "Neither returned Chapter nor Verse match"
    return 3;
  fi;
}

getv 'votd';

for bk in $sblbks; do
  debug 2 bk $bk;
  debug 2 ch $ch;
  debug 2 vs $vs;
  getv $bk $ch $vs;
done;

getv 'random';

echo -e "$netcpyrt";