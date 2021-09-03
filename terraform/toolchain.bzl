load("//terraform:provider.bzl", "TerraformInfo")

toolchains = {
    "macos_amd64": {
        "os": "darwin",
        "arch": "amd64",
        "sha": "2c2d9d435712f4be989738b7899917ced7c12ab05b8ddc14359ed4ddb1bc9375",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_amd64": {
        "os": "linux",
        "arch": "amd64",
        "sha": "43806e68f7af396449dd4577c6e5cb63c6dc4a253ae233e1dddc46cf423d808b",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
}

url_template = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{os}_{arch}.zip"

def _terraform_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        barcinfo = TerraformInfo(
            sha = ctx.attr.sha,
            url = ctx.attr.url,
        ),
    )
    return [toolchain_info]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "sha": attr.string(),
        "url": attr.string(),
    },
)

def _format_url(version, os, arch):
    return url_template.format(version = version, os = os, arch = arch)

def declare_terraform_toolchains(version):
    for key, info in toolchains.items():
        url = _format_url(version, info["os"], info["arch"])
        name = "terraform_{}".format(key)
        toolchain_name = "{}_toolchain".format(name)

        terraform_toolchain(
            name = name,
            url = url,
            sha = info["sha"],
        )
        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = info["exec_compatible_with"],
            target_compatible_with = info["target_compatible_with"],
            toolchain = name,
            toolchain_type = "@io_bazel_rules_terraform//:toolchain_type",
        )

def _detect_platform_arch(ctx):
    if ctx.os.name == "linux":
        platform = "linux"
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname not in ["x86_64", "i386"]:
                fail("Unable to determing processor architecture.")

            arch = "amd64" if uname == "x86_64" else "i386"
        else:
            fail("Unable to determing processor architecture.")
    elif ctx.os.name == "mac os x":
        platform, arch = "darwin", "amd64"
    elif ctx.os.name.startswith("windows"):
        platform, arch = "windows", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return platform, arch

def _terraform_build_file(ctx, platform, version):
    ctx.file("ROOT")
    ctx.template(
        "BUILD.bazel",
        Label("@io_bazel_rules_terraform//terraform:BUILD.terraform.bazel"),
        executable = False,
        substitutions = {
            "{name}": "terraform_executable",
            "{exe}": ".exe" if platform == "windows" else "",
            "{version}": version,
        },
    )

def _remote_terraform(ctx, url, sha):
    ctx.download_and_extract(
        url = url,
        sha256 = sha,
        type = "zip",
        output = "terraform",
    )

def _terraform_register_toolchains_impl(ctx):
    platform, arch = _detect_platform_arch(ctx)
    version = ctx.attr.version
    _terraform_build_file(ctx, platform, version)

    host = "{}_{}".format(platform, arch)
    info = toolchains[host]
    url = _format_url(version, info["os"], info["arch"])
    _remote_terraform(ctx, url, info["sha"])

_terraform_register_toolchains = repository_rule(
    _terraform_register_toolchains_impl,
    attrs = {
        "version": attr.string(),
    },
)

def terraform_register_toolchains(version = None):
    # TODO version is required
    _terraform_register_toolchains(
        name = "register_terraform_toolchains",
        version = version,
    )
