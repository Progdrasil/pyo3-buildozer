# PYO3 on android

This is an example of building a [PYO3] application using [buildozer].

**WARNING: there is currently a linking issue**

[buildozer]: https://github.com/kivy/buildozer
[pyo3]: https://github.com/PyO3/pyo3

#### Docker build

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