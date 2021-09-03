workspace(name = "io_bazel_rules_terraform")

# Variables
# SKYLIB
skylib_version = "1.0.3"

skylib_sha = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c"

# RULES_GO
rules_go_version = "0.24.5"

rules_go_sha = "d1ffd055969c8f8d431e2d439813e42326961d0942bdf734d2c95dc30c369566"

# GAZELLE
gazelle_version = "0.22.2"

gazelle_sha = "b85f48fa105c4403326e9525ad2b2cc437babaa6e15a3fc0b1dbab0ab064bc7c"

# SKYLIB
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/{0}/bazel-skylib-{0}.tar.gz".format(skylib_version),
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{0}/bazel-skylib-{0}.tar.gz".format(skylib_version),
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# BUILDIFIER
http_archive(
    name = "io_bazel_rules_go",
    sha256 = rules_go_sha,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v{0}/rules_go-v{0}.tar.gz".format(rules_go_version),
        "https://github.com/bazelbuild/rules_go/releases/download/v{0}/rules_go-v{0}.tar.gz".format(rules_go_version),
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "bazel_gazelle",
    sha256 = gazelle_sha,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v{0}/bazel-gazelle-v{0}.tar.gz".format(gazelle_version),
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v{0}/bazel-gazelle-v{0}.tar.gz".format(gazelle_version),
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

http_archive(
    name = "com_google_protobuf",
    strip_prefix = "protobuf-master",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/master.zip"],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

http_archive(
    name = "com_github_bazelbuild_buildtools",
    strip_prefix = "buildtools-master",
    url = "https://github.com/bazelbuild/buildtools/archive/master.zip",
)

# TERRAFORM
# load("@io_bazel_rules_terraform//terraform:terraform.bzl", "terraform_register_toolchains")

# terraform_register_toolchains("0.12.8")
