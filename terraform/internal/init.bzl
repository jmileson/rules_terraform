""""""

def _terraform_init(ctx):
    deps = depset(ctx.files.srcs)
    ctx.actions.run(
        executable = ctx.executable._exec,
        inputs = deps.to_list(),
        outputs = [ctx.outputs.out],
        mnemonic = "TerraformInitialize",
        arguments = [
            "init",
            #"-out={0}".format(ctx.outputs.out.path),
            deps.to_list()[0].dirname,
        ],
    )

terraform_init = rule(
    implementation = _terraform_init,
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
)
