"""Public interface for rules_terraform."""

load("//terraform/internal:apply.bzl", _terraform_apply = "terraform_apply")
load("//terraform/internal:init.bzl", _terraform_init = "terraform_init")
load("//terraform/internal:plan.bzl", _terraform_plan = "terraform_plan")
load("//terraform/internal:toolchain.bzl", _terraform_register_toolchains = "terraform_register_toolchains")

terraform_register_toolchains = _terraform_register_toolchains

terraform_init = _terraform_init

terraform_plan = _terraform_plan

terraform_apply = _terraform_apply
