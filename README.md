# PYO3 on android

This is an example of building a [PYO3] Library using [buildozer].

[buildozer]: https://github.com/kivy/buildozer
[pyo3]: https://github.com/PyO3/pyo3

## Docker build

You can build the buildozer image with the following command:

```shell
docker build -t buildozer -f buildozer.Dockerfile .
```

You can then start a build from outside the container with the following command:

```shell
docker run --rm -v "$(pwd)":/home/user/hostcwd buildozer android debug
```

However the easiest way to deal with buildozer through docker is to run it interactivelly by entering it with bash.
To run on a device from docker you need to mount the usb bus to the container in priviledged mode.
Putting it all together looks like so:

```shell
docker run --rm -v "$(pwd)":/home/user/hostcwd -v /dev/bus/usb:/dev/bus/usb --privileged -it --entrypoint=bash buildozer
```

Now you can run any of the buildozer commands.
The most usefull ones are to build

```sh
buildozer android debug
```

And to deploy run and print the debug logs.
For debugging it is easiest to redirect to a file for later analysis.

```sh
buildozer android deploy run logcat > out.log
```

## Troubleshooting

If you are getting a runtime error of `ImportError: dlopen failed: cannot locate symbol "PyExc_BaseException"` or the same but for `_Py_NoneStruct` there is a workaround while the issue is being treated [upstream].

You must link to the `m` of libpython by either setting the rust flags in a `.cargo/config` or as the `RUSTFLAGS` environement variable at build time.

`.cargo/config`
```toml
[target.aarch64-linux-android]
rustflags = [ "-C", "link-args=-L<LD_LIBRARY_PATH> -lpythonX.Ym"]

[target.armv7-linux-androideabi]
rustflags = [ "-C", "link-args=-L<LD_LIBRARY_PATH> -lpythonX.Ym"]
```

Or as we do here, the `RUSTFLAGs="-C link-args=-L<LD_LIBRARY_PATH> -lpythonX.Ym"` variable is set in the [Python for android recipe].

[upstream]: https://github.com/PyO3/pyo3/issues/1077
[Python for android recipe]: https://github.com/Progdrasil/pyo3-buildozer/blob/master/p4a/my_lib/__init__.py#L24
