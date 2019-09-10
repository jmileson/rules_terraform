# BUILDIFIER
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
workspace(name = "io_bazel_rules_terraform")

# TERRAFORM
load("@io_bazel_rules_terraform//terraform:terraform.bzl", "terraform_register_toolchains")

terraform_register_toolchains("0.12.8")
