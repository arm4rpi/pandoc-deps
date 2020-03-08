# pandoc-deps

![Pandoc aarch64 Deps](https://github.com/arm4rpi/pandoc-deps/workflows/Pandoc%20aarch64%20Deps/badge.svg) ![Pandoc armv7l Deps](https://github.com/arm4rpi/pandoc-deps/workflows/Pandoc%20armv7l%20Deps/badge.svg)

prebuilt pandoc deps for CI. use for https://github.com/arm4rpi/pandoc-arm


These deps are build with Github Actions. Before build pandoc, need update the `.cabal` directory. For example, if build with root user:

```
sed -i 's/\/home\/runner/\/root/g' /root/.cabal/store/ghc-8.6.5/package.db/*.conf
ghc-pkg recache -v -f /root/.cabal/store/ghc-8.6.5/package.db/
```
