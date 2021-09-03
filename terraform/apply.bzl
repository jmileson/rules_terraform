""""""

def _terraform_apply(ctx):
    deps = depset(ctx.files.srcs)
    ctx.actions.run(
        executable = ctx.executable._exec,
        inputs = deps.to_list(),
        outputs = [ctx.outputs.out],
        mnemonic = "TerraformInitialize",
        arguments = [
            "apply",
            "-out={0}".format(ctx.outputs.out.path),
            deps.to_list()[0].dirname,
        ],
    )

terraform_apply = rule(
    implementation = _terraform_apply,
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
    },
    outputs = {"out": "%{name}.out"},
    executable = True,
)
