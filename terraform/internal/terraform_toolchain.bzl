"""
Implementation of the terraform_toolchain rule 
for use when registering toolchains.
"""

load("//terraform/internal:providers.bzl", "TerraformInfo")

def _terraform_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        terraform_info = TerraformInfo(
            name = ctx.label.name,
            arch = ctx.attr.arch,
            os = ctx.attr.os,
            version = ctx.attr.version,
        ),
    )
    return [toolchain_info]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "arch": attr.string(),
        "os": attr.string(),
        "version": attr.string(),
    },
)
