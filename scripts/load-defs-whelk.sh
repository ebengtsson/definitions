#!/usr/bin/env bash

WHELK=$1
FILTER=$2
DOBUILD=$3
BUILDBASE="build"

put() {
    if [[ $3 == *"$FILTER"* ]]; then
        echo "PUT '$1' to <$3> as $2"
        curl -XPUT -H "Content-Type:$2" --data-binary @$1 $3?data
    fi
}

# Generate datasets
if [[ $DOBUILD != "--nobuild" && $FILTER == "" ]]; then
    echo "Compile definitions..."
    python datasets.py -c cache/ -o $BUILDBASE/
    echo "Done."
fi

# Load JSON-LD contexts
libcontext=$BUILDBASE/lib-context.jsonld
put $libcontext application/ld+json ${WHELK}/sys/context/lib.jsonld
for ctx in owl skos; do
    put sys/context/${ctx}.jsonld application/ld+json ${WHELK}/sys/context/${ctx}.jsonld
done

# Load standalone documents
for doc in terms schemes; do
    put $BUILDBASE/${doc}.jsonld application/ld+json ${WHELK}/def/$doc
done

# Load datasets
for dataset in languages countries nationalities relators enum/{content,carrier,record}; do
    for file in $BUILDBASE/$dataset/*.jsonld; do
        slug=$(basename -s .jsonld $file)
        put $file application/ld+json ${WHELK}/def/${dataset}/$slug
    done
done
