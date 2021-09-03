load("//terraform:provider.bzl", "TerraformPlanInfo")

def _terraform_plan_impl(ctx):
    deps = depset(ctx.files.srcs)

    # TODO compatibility with windows
    exe = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.expand_template(
        template = Label("//terraform:terraform_plan.sh.tpl"),
        output = exe,
        substitutions = {
            "%{args}": deps.to_list()[0].dirname,
            "%{executable}": _get_runfile_path(ctx, ctx.executable._exec),
            "%{out}": ctx.outputs.out.path,
        },
        is_executable = True,
    )
    return TerraformPlanInfo(
        plan = ctx.outputs.out,
    )
    # ctx.actions.run(
    #     executable = ctx.executable._exec,
    #     inputs = deps.to_list(),
    #     outputs = [ctx.outputs.out],
    #     mnemonic = "TerraformInitialize",
    #     arguments = [
    #         "plan",
    #         "-out={0}".format(ctx.outputs.out.path),
    #         deps.to_list()[0].dirname,
    #     ],
    # )

terraform_plan = rule(
    implementation = _terraform_plan_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "tmpl": attr.label(
            default = Label("//terraform:terraform_plan.sh.tpl"),
            allow_single_file = True,
            doc = "The script template to use.",
        ),
        "_exec": attr.label(
            default = Label("@register_terraform_toolchains//:terraform_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
    },
    outputs = {"out": "%{name}.out"},
    executable = True,
)
