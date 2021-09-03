""""""
TerraformInfo = provider(
    doc = "Information about how to invoke Terraform.",
    fields = ["sha", "url"],
)

TerraformPlanInfo = provider(
    doc = "Information about a Terraform plan.",
    fields = {
        "plan": "the plan file",
    },
)
