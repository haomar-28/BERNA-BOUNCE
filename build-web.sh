#!/bin/sh
set -eu

# Requires Emscripten (emcc/emcmake) to be installed and activated.
# Example: source /path/to/emsdk/emsdk_env.sh

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"

command -v emcmake >/dev/null 2>&1 || { echo "ERROR: emcmake not found. Install/activate Emscripten first."; exit 1; }
command -v emcc >/dev/null 2>&1 || { echo "ERROR: emcc not found. Install/activate Emscripten first."; exit 1; }

rm -rf build-web web-dist
emcmake cmake -S . -B build-web -DCMAKE_BUILD_TYPE=Release
cmake --build build-web --target BounceClassic -j 2

mkdir -p web-dist
cp build-web/BounceClassic.html web-dist/index.html
for f in build-web/BounceClassic.js build-web/BounceClassic.wasm build-web/BounceClassic.data; do
  [ -f "$f" ] && cp "$f" web-dist/
done
cp vercel.json web-dist/

# Emscripten's generated loader expects its companion files beside index.html.
# The data file is only produced when --preload-file is active.

echo
printf '%s\n' 'Web build complete.'
printf '%s\n' 'Deploy the contents of web-dist/ to Vercel.'
