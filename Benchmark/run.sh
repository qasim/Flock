#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"

function run {
    ./run.sh $1
}

case $1 in
    build)
        swift build -c release
    ;;

    benchmark)
        run build
        case $2 in
            fileSize)
                SIZES="1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824"
            ;;
            connections)
                SIZES="1 2 4 8"
            ;;
        esac
        FILTER="${2}=x"
        .build/release/benchmark run \
            results.json \
            --filter "$FILTER" \
            --sizes $SIZES \
            --disable-cutoff true \
            --format pretty \
            --mode replace-all
    ;;

    render)
        run build
        mkdir -p Charts
        FILTER="${2}=x"
        .build/release/benchmark render \
            results.json \
            "Charts/${2}.png" \
            --filter "$FILTER" \
            --linear-time \
            --amortized false
    ;;
esac
