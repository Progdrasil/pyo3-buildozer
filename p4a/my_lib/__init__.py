from pythonforandroid.toolchain import current_directory, shprint, shutil
from pythonforandroid.recipe import NDKRecipe
from pythonforandroid.logger import info
import json
import sh
import os.path
from os.path import join
from typing import List


class MyLibRecipe(NDKRecipe):
    version = "master"
    url = "git+file:///home/user/hostcwd/"  # path in the docker buildozer image
    depends: List[str] = ["python3", "setuptools"]

    def get_recipe_env(self, arch) -> dict:
        env = super().get_recipe_env(arch)
        link_root = self.ctx.python_recipe.link_root(arch.arch)
        env["PYO3_CROSS_INCLUDE_DIR"] = self.ctx.python_recipe.include_root(arch.arch)
        env["PYO3_CROSS_LIB_DIR"] = link_root
        env["LD_LIBRARY_PATH"] = link_root
        env["ANDROID_NDK_HOME"] = self.ctx.ndk_dir
        env["ANDROID_SDK_HOME"] = self.ctx.sdk_dir
        env["RUSTFLAGS"] = f"-C link-args=-L{link_root} -lpython3.8m"

        return env

    def should_build(self, arch):
        return not os.path.isfile(
            "{}/my_lib.so".format(self.ctx.get_site_packages_dir(arch.arch))
        )

    def get_target(self, arch) -> str:
        if arch.command_prefix == "arm-linux-androideabi":
            target = "armv7-linux-androideabi"
        else:
            target = arch.command_prefix
        return target

    def prebuild_arch(self, arch):
        rustup = sh.Command("rustup")
        target = self.get_target(arch)
        shprint(rustup, "target", "add", target)

    def build_arch(self, arch):  # build_compiled_components(self, arch)
        info("Building compiled components for my_lib")
        env = self.get_recipe_env(arch)
        info(json.dumps(env, indent=2))

        target = self.get_target(arch)
        platform = self.ctx.android_api
        build_dir = self.get_build_dir(arch.arch)
        lib_dir = join(build_dir, "target", target, "debug")
        with current_directory(build_dir):
            cargo = sh.Command("cargo")
            shprint(
                cargo,
                "ndk",
                "--platform",
                str(platform),
                "--target",
                target,
                "build",
                # "--release",
                _env=env,
            )
            shutil.copyfile(
                join(lib_dir, "libmy_lib.so"),
                join(self.ctx.get_site_packages_dir(arch.arch), "my_lib.so"),
            )


recipe = MyLibRecipe()
