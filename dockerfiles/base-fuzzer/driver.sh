#!/bin/bash

OLD_ASAN_OPTIONS=$ASAN_OPTIONS
OLD_CFLAGS=$CFLAGS
OLD_CXX_FLAGS=$CXXFLAGS
OLD_PATH=$PATH

echo ========== BUILDING CLANG ==========
bash $BASH_FLAGS /src/scripts/build_clang.sh

export CC="/work/llvm/bin/clang"
export CXX="/work/llvm/bin/clang++"
export PATH=/work/llvm/bin:$PATH
export CFLAGS="$CFLAGS $SANITIZER_OPTIONS $COVERAGE_OPTIONS"
export CXXFLAGS="$CXXFLAGS $SANITIZER_OPTIONS $COVERAGE_OPTIONS"

# build libfuzzer
mkdir -p /work/libfuzzer
cd /work/libfuzzer
for f in /src/llvm/lib/Fuzzer/*cpp; do
  $CXX -std=c++11 $OLD_CXXFLAGS $SANITIZER_OPTIONS -IFuzzer -c $f &
done
wait

mkdir -p /work/logs

echo ========== BUILDING PROJECT ==========
# asan could get in the way of configure scripts.
export ASAN_OPTIONS=""
bash $BASH_FLAGS /src/scripts/build.sh 2>&1 >> /work/logs/build.log

export ASAN_OPTIONS=$OLD_ASAN_OPTIONS
echo ========== RUNNING FUZZER ==========
bash $BASH_FLAGS /src/scripts/run.sh
