"""
Constants to support different platforms.
"""
BAZEL_OS_CONSTRAINTS = {
    "darwin": "@platforms//os:osx",
    "freebsd": "@platforms//os:freebsd",
    "linux": "@platforms//os:linux",
    "openbsd": "@platforms//os:openbsd",
    "windows": "@platforms//os:windows",
}

BAZEL_ARCH_CONSTRAINTS = {
    "386": "@platforms//cpu:x86_32",
    "amd64": "@platforms//cpu:x86_64",
    "arm": "@platforms//cpu:arm",
    "arm64": "@platforms//cpu:aarch64",
}

UNAME_ARCH = {
    "aarch64": "arm64",
    "arm": "arm",
    "x86_32": "386",
    "x86_64": "amd64",
}

OS_ARCH = (
    ("darwin", "amd64"),
    ("darwin", "arm64"),
    ("freebsd", "386"),
    ("freebsd", "amd64"),
    ("freebsd", "arm"),
    ("linux", "amd64"),
    ("linux", "386"),
    ("linux", "arm"),
    ("linux", "arm64"),
    ("openbsd", "386"),
    ("openbsd", "amd64"),
    ("solaris", "amd64"),
    ("windows", "386"),
    ("windows", "amd64"),
)

def _constraints(os, arch):
    return [
        BAZEL_OS_CONSTRAINTS.get(os),
        BAZEL_ARCH_CONSTRAINTS.get(arch),
    ]

def _generate_platforms():
    platforms = []
    for os, arch in os_ARCH.items():
        name = "{os}_{arch}".format(os = os, arch = arch)
        constraints = _constraints(os, arch)
        toolchains.append(struct(
            name = name,
            arch = arch,
            os = os,
            constraints = constraints,
        ))
    return platforms

PLATFORMS = _generate_platforms()
