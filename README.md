# Rules Terraform
Terraform rules for Bazel

# Usage

In your `WORKSPACE`

```
http_archive(
    name = "io_bazel_rules_terraform",
    sha256 = "cedf034b14163f339108f4ce6ebf75fab7967ac614f56d3829476d1a86d7ffd3",
    urls = [
        "https://github.com/jmileson/rules_terraform/archive/v0.1.0.tar.gz",
    ],
)


load("@io_bazel_rules_terraform//terraform:terraform.bzl", "terraform_register_toolchains")

terraform_register_toolchains("0.12.8")
```

Import the rules you want to use in your build file:

```
load("@io_bazel_rules_terraform//terraform:terraform.bzl", "terraform_plan")

terraform_plan(
    name = "plan",
    srcs = glob(["**/*.tf"])
)
```


