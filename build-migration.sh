#!/bin/bash
timestamp=`date +%Y%m%d%H%M%S`
wget 'http://localhost:8890/sparql?default-graph-uri=&query=CONSTRUCT+%7B%0D%0A++%3Fconversation+%3Fp+%3Fo.%0D%0A++%3Fconversation+%3Chttp%3A%2F%2Fschema.org%2FhasPart%3E+%3Fmessage.%0D%0A++%3Fmessage+%3Fmp+%3Fmo.%0D%0A++%3Fpart+%3Fpp+%3Fpo.%0D%0A++%3Ffile+%3Ffp+%3Ffo.%0D%0A%7D%0D%0A+WHERE+%7B%0D%0AGRAPH+%3Chttp%3A%2F%2Fmu.semte.ch%2Fapplication%3E+%7B%0D%0A++%3Fconversation+%3Fp+%3Fo.%0D%0A++%3Fconversation+%3Chttp%3A%2F%2Fschema.org%2FhasPart%3E+%3Fmessage.%0D%0A++%3Fmessage+%3Fmp+%3Fmo.%0D%0A++%3Fmessage+%3Chttp%3A%2F%2Fschema.org%2Frecipient%3E+%3Fbestuur.%0D%0A++++OPTIONAL+%7B%0D%0A++++++%3Fmessage+%3Chttp%3A%2F%2Fwww.semanticdesktop.org%2Fontologies%2F2007%2F01%2F19%2Fnie%23hasPart%3E+%3Fpart.%0D%0A++++++%3Fpart+%3Fpp+%3Fpo.%0D%0A++++++%3Ffile+%3Chttp%3A%2F%2Fwww.semanticdesktop.org%2Fontologies%2F2007%2F01%2F19%2Fnie%23dataSource%3E+%3Fpart%3B%0D%0A++++++++++++%3Ffp+%3Ffo.%0D%0A%7D%0D%0A%7D%0D%0A%7D&should-sponge=&format=text%2Fplain&timeout=0&debug=on&run=+Run+Query+' -O $timestamp-berichten.ttl
echo "http://mu.semte.ch/graphs/import/berichten-tmp" > $timestamp-berichten.graph
sleep 1
timestampquery=`date +%Y%m%d%H%M%S`
echo '
INSERT {
GRAPH ?graph {
?conversation ?p ?o.
?message ?mp ?mo.
}
GRAPH <http://mu.semte.ch/graphs/public> {
?part ?pp ?po.
?file ?fp ?fo.
}
}
WHERE {
GRAPH <http://mu.semte.ch/graphs/import/berichten-tmp> {
  ?conversation ?p ?o.
  ?conversation <http://schema.org/hasPart> ?message.
  ?message ?mp ?mo.
  ?message <http://schema.org/recipient> ?bestuur.
    OPTIONAL {
      ?message <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#hasPart> ?part.
      ?part ?pp ?po.
      ?file <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#dataSource> ?part;
            ?fp ?fo.
  }
}
GRAPH <http://mu.semte.ch/graphs/public> {
  ?bestuur <http://mu.semte.ch/vocabularies/core/uuid> ?uuid
  BIND(IRI(CONCAT("http://mu.semte.ch/graphs/organizations/", ?uuid, "/LoketLB-berichtenGebruiker")) as ?graph)
}
};

DROP SILENT GRAPH <http://mu.semte.ch/graphs/import/berichten-tmp> ' > $timestampquery-berichten.sparql

zip $timestamp-berichten-package.zip $timestamp-berichten.* $timestampquery-berichten.sparql data/files/*pdf
rm -rf data/files $timestamp-berichten.* $timestampquery-berichten.sparql
docker-compose down
rm -rf data/db/virtuoso* data/db/.dba_pwd_set data/db/.data_loaded && git checkout virtuoso.ini
