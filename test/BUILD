load("@io_bazel_rules_terraform//terraform:terraform.bzl", "terraform_init", "terraform_plan", "terraform_version")

SRCS = glob(["**/*.tf"])

terraform_init(
    name = "init",
    srcs = SRCS,
)

terraform_plan(
    name = "test",
    srcs = SRCS,
)

terraform_version(name = "version")
