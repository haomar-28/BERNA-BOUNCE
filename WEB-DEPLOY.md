# BOUNCE CLASSIC — Web / Vercel build

This folder is prepared for an Emscripten WebAssembly build of the latest `finalGameShowdown.c`.

## 1. Install/activate Emscripten

On the Mac, install the Emscripten SDK (`emsdk`) and activate the SDK environment so `emcc` and `emcmake` are on PATH.

## 2. Build the browser version

From this folder:

```sh
./build-web.sh
```

The finished static site is created in `web-dist/` with:

- `index.html`
- `BounceClassic.js`
- `BounceClassic.wasm`
- `BounceClassic.data`
- `vercel.json`

## 3. Deploy to Vercel

```sh
cd web-dist
vercel --prod
```

Or import the project into Vercel and use `web-dist` as the deployment/output directory after running the build.

### Important
The uploaded archive did not contain a compiled `.wasm`/`.js`/`.data` browser build, and this environment does not have Emscripten installed. Therefore this package is **web-build-ready**, not falsely presented as an already-compiled Vercel site.
