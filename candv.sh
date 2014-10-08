#!/bin/bash
DEBUG=0
base_url='http://labs.bible.org/api/?passage='
ch="$1"
vs="$2"
passage=''
format='formatting=plain'
type='type=json'
otbooks='Gen Exo Lev Num Deu Jos Jdg Rut 1Sa 2Sa 1Ki 2Ki 1Ch 2Ch Ezr Neh Est Job Psa Pro Ecc Sos Isa Jer Lam Eze Dan Hos Joe Amo Oba Jon Mic Nah Hab Zep Hag Zec Mal'
ntbooks='Mat Mar Luk Joh Act Rom 1Co 2Co Gal Eph Phi Col 1Th 2Th 1Ti 2Ti Tit Phm Heb Jam 1Pe 2Pe 1Jo 2Jo 3Jo Jud Rev'

# List of Abbreviations (for the NET Bible Footnotes)
# From: https://bible.org/list-abbreviations-net-bible-footnotes
abbbks='Gen Exod Lev Num Deut Josh Judg Ruth 1%20Sam 2%20Sam 1%20Kgs 2%20Kgs 1%20Chr 2%20Chr Ezra Neh Esth Job Ps Prov Eccl Song Isa Jer Lam Ezek Dan Hos Joel Amos Obad Jonah Mic Nah Hab Zeph Hag Zech Mal Bar Add%20Dan Pr%20Azar Bel Sg%20Three Sus 1%20Esd 2%20Esd Add%20Esth Ep%20Jer Jdt 1%20Macc 2%20Macc 3%20Macc 4%20Macc Pr%20Man Ps%20151 Sir Tob Wis Matt Mark Luke John Acts Rom 1%20Cor 2%20Cor Gal Eph Phil Col 1%20Thess 2%20Thess 1%20Tim 2%20Tim Titus Phlm Heb Jas 1%20Pet 2%20Pet 1%20John 2%20John 3%20John Jude Rev'
# Biblical Books (not including Apocrypha/Deuterocanonicals)
# From: http://people.ucalgary.ca/~eslinger/genrels/SBLStandAbbrevs.html
sblbks='Gen Ex Lev Num Deut Josh Judg Ruth 1Sam 2Sam 1Kgs 2Kgs 1Chr 2Chr Ezra Neh Esth Job Ps Prov Eccl Song Isa Jer Lam Ezek Dan Hos Joel Amos Oba Jonah Mic Nah Hab Zeph Hag Zech Mal Mt Mk Lk Jn Acts Rom 1Cor 2Cor Gal Eph Phil Col 1Thes 2Thes 1Tim 2Tim Tit Phm Heb Jas 1Pet 2Pet 1Jn 2Jn 3Jn Jude Rev'
function debug {
  if (( $DEBUG == 1 )); then
    echo "DEBUG: $@" > /dev/stderr;
  fi;
}
# for bk in $otbooks $ntbooks; do
  for bk in $sblbks; do
  debug bk $bk;
  debug ch $ch;
  debug vs $vs;
  get="${base_url}${bk}%20${ch}:${vs}&${format}&${type}"
  debug get $get;
  result=$(curl -s "${get}");
  debug result $result;
  rbk=$(echo "$result" | jq '.[].bookname' | tr -d '"');
  debug rbk $rbk;
  rch=$(echo "$result" | jq '.[].chapter' | tr -d '"');
  debug rch $rch;
  rvs=$(echo "$result" | jq '.[].verse' | tr -d '"');
  debug rvs $rvs;
  txt=$(echo "$result" | jq '.[].text' | tr -d '"');
  debug txt $txt;
  if [[ $ch == $rch ]] && [[ $vs == $rvs ]]; then
    echo "${rbk} ${rch}:${rvs} - '${txt}'";
  fi;
  sleep 0;
done;