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
        case $3 in
            fileSize)
                case $2 in
                    local)
                        SIZES="1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824"
                    ;;
                    remote)
                        SIZES="5242880 10485760 52428800 104857600 209715200 536870912 1073741824"
                    ;;
                esac
            ;;
            connections)
                SIZES=$(seq 1 16)
            ;;
        esac
        FILTER="${2}, ${3}=x"
        .build/release/benchmark run \
            results.json \
            --filter "$FILTER" \
            --disable-cutoff true \
            --format pretty \
            --sizes $SIZES
    ;;

    render)
        run build
        mkdir -p Charts
        FILTER="${2}, ${3}=x"
        .build/release/benchmark render \
            results.json \
            "Charts/${2}_${3}.png" \
            --filter "$FILTER" \
            --amortized false
    ;;
esac
