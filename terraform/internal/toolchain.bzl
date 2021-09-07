"""
Exposes terraform_register_toolchains to support 
different Terraform toolchains per platform.
"""

load("//terraform/internal:platform.bzl", "OS_ARCH", "PLATFORMS", "UNAME_ARCH", "generate_toolchain_names", _toolchain_name = "toolchain_name")
load("//terraform/internal:terraform_toolchain.bzl", "terraform_toolchain")

bin_url_tpl = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{os}_{arch}.zip"
checksums_url_tpl = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_SHA256SUMS"

def _detect_os_arch(ctx):
    """
    Determine the OS and CPU Achitecture of the running system.

    Returns (os, arch)
    """
    arches = {}
    for plat, arch in OS_ARCH:
        if plat not in arches:
            arches[plat] = []
        arches[plat].append(arch)

    if ctx.os.name in ("linux", "darwin", "openbsd", "solaris", "freebsd"):
        os = ctx.os.name
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            arch = UNAME_ARCH.get(uname)
            if arch not in arches[os]:
                fail("Unable to determine processor architecture for {}".format(os))
        else:
            fail("Unable to determine processor architecture for {}".format(os))
    elif ctx.os.name.startswith("windows"):
        os = "windows"
        res = ctx.execute(["SET", "Processor"])
        if res.return_code == 0:
            stdout = res.stdout.strip()
            if not stdout:
                fail("unable to determine processor architecture for {}".format(os))
            _, proc = stdout.split("=")

            if proc not in ("x86", "x64"):
                fail("unsupported processor architecture for {}".format(os))
            arch = "amd64" if proc == "x64" else "386"
    else:
        fail("Unsupported operating system: {}".format(ctx.os.name))

    return os, arch

def _parse_checksums(data):
    """Parse Terraform release checksums from a release checksum file

    data: str, contents of the checksum file.

    Returns a dict[(os, arch), checksum].
    """
    checksums = {}
    for line in data.split("\n"):
        line = line.strip()

        if not line:
            continue

        checksum, filename = line.split(" ", 1)
        checksum = checksum.strip()
        name, _ = filename.rsplit(".", 1)
        _, _, os, arch = name.strip().split("_")
        os = os.strip()
        arch = arch.strip()

        checksums[(os, arch)] = checksum

    return checksums

def _checksum(ctx, version, os, arch):
    """Get the checksum for a specific release of Terraform.

    version: the version of Terraform to checksum
    os: the OS the version of Terraform was compiled against
    arch: the architecture the version of Terraform was compiled against

    Returns checksum
    """
    url = checksums_url_tpl.format(version = version)
    output = "terraform_{version}_SHA256SUMS".format(version = version)
    ctx.download(
        url = [url],
        output = output,
    )
    data = ctx.read(output)

    checksums = _parse_checksums(data)

    bin_checksum = checksums.get((os, arch), None)
    if not bin_checksum:
        fail("no checksum present to verify toolchain")

    return bin_checksum

def _download_terraform(ctx, version, os, arch, sha256):
    """Download a release of Terraform

    version: the version of Terraform to download
    os: the OS the version of Terraform was compiled against
    arch: the architecture the version of Terraform was compiled against
    sha256: the checksum of the downloaded file

    """
    url = bin_url_tpl.format(version = version, os = os, arch = arch)
    ctx.download_and_extract(
        url = url,
        sha256 = sha256,
        type = "zip",
        output = "terraform",
    )

def _terraform_download(ctx, os, arch, version):
    """Download a version of Terraform specific an OS and Architecture."""
    if not os and not arch:
        fail("arch and os not set.")
    if not os:
        fail("arch not set, but os not set")
    if not arch:
        fail("os set, but arch not set")

    if not version:
        fail("version not set")

    ctx.report_progress("Fetching checksums for Terraform toolchain")
    sha256 = _checksum(ctx, version, os, arch)

    ctx.report_progress("Downloading Terraform toolchain")
    _download_terraform(ctx, version, os, arch, sha256)

def declare_terraform_toolchains(version):
    """Registers terraform_toolchain and toolchain targets for each platform.

    Used exclusively in the BUILD.bazel file generated when calling
    terraform_register_toolchains. The set of toolchains is known
    ahead of time, but a template is used to keep values from
    //terraform/internal:platform.bzl in sync between the rules defined
    here and the BUILD file required to make this set of rules available to
    other workspaces.
    """
    for plat in PLATFORMS:
        toolchain_name = _toolchain_name(plat)
        impl_name = "{}_impl".format(toolchain_name)

        terraform_toolchain(
            name = impl_name,
            os = plat.os,
            arch = plat.arch,
            version = version,
        )
        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = plat.constraints,
            target_compatible_with = plat.constraints,
            toolchain = ":{}".format(impl_name),
            toolchain_type = "@rules_terraform//terraform:toolchain",
        )

def _register_toolchains():
    labels = [
        "@rules_terraform//:{}".format(name)
        for name in generate_toolchain_names()
    ]
    native.register_toolchains(*labels)

def _terraform_register_toolchains_impl(ctx):
    """Register Terraform toolchains for a specific version."""
    os, arch = _detect_os_arch(ctx)
    version = ctx.attr.version

    ctx.file("ROOT")
    ctx.template(
        "BUILD.bazel",
        Label("@rules_terraform//terraform/internal:BUILD.terraform.bazel"),
        executable = False,
        substitutions = {
            "{exe}": ".exe" if os == "windows" else "",
            "{name}": "terraform_executable",
            "{version}": version,
        },
    )

    _terraform_download(ctx, os, arch, version)

_terraform_register_toolchains = repository_rule(
    _terraform_register_toolchains_impl,
    attrs = {
        "version": attr.string(),
    },
)

def terraform_register_toolchains(version):
    """Register Terraform toolchains for a specific version."""
    _terraform_register_toolchains(
        name = "register_terraform_toolchains",
        version = version,
    )
    _register_toolchains()
