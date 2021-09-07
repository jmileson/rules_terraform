"""
Exposes terraform_plan to support `terraform plan` execution.
"""

load("//terraform/internal:providers.bzl", "TerraformPlanInfo")

def _terraform_plan_impl(ctx):
    deps = depset(ctx.files.srcs)

    # generate an empty planfile
    planfile = ctx.actions.declare_file(ctx.label.name + ".plan")
    ctx.actions.write(planfile, "")

    # TODO compatibility with windows
    exe = ctx.actions.declare_file(ctx.label.name + ".sh")
    print(ctx.toolchains["@rules_terraform//:terraform_executable"])

    ctx.actions.expand_template(
        template = ctx.file._tmpl,
        output = exe,
        substitutions = {
            "%{args}": deps.to_list()[0].dirname,
            "%{executable}": ctx.executable._exec.path,
            "%{out}": planfile.path,
        },
        is_executable = True,
    )

    return [
        DefaultInfo(executable = exe),
        TerraformPlanInfo(
            plan = planfile.path,
        ),
    ]

terraform_plan = rule(
    implementation = _terraform_plan_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "_exec": attr.label(
            default = Label("@register_terraform_toolchains//:terraform_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
        "_tmpl": attr.label(
            default = Label("//terraform/internal:terraform_plan.sh.tpl"),
            allow_single_file = True,
            doc = "The script template to use.",
        ),
    },
    toolchains = ["@rules_terraform//terraform:toolchain"],
    executable = True,
)
