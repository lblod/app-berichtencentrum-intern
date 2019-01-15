#!/bin/bash

timestamp=`date +%Y%M%d%H%M%S`
echo "dump_nquads ('dumps', 1, 10000000, 0);" | docker-compose exec -T db isql-v
grep "http://mu.semte.ch/application" data/db/dumps/output000001.nq | rapper -i nquads -o ntriples -I http://example.org -  > $timestamp-berichten.ttl
echo "http://mu.semte.ch/graphs/import/berichten-tmp" > $timestamp-berichten.graph
sleep 1
timestampquery=`date +%Y%M%d%H%M%S`
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
rm -rf data/db
