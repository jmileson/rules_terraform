"""
Providers for various rules.
"""
TerraformInfo = provider(
    doc = "Information about how to invoke Terraform.",
    fields = {
        "arch": "The architecture the toolchain is compiled for.",
        "name": "The name of the toolchain.",
        "os": "The operating system the toolchain is compiled for.",
    },
)

TerraformPlanInfo = provider(
    doc = "Information about a Terraform plan.",
    fields = {
        "plan": "the plan file",
    },
)
