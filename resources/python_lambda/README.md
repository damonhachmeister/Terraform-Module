# This module packages up a python lambda. It will place the generated .ZIP in
# ${var.zip_output_directory}. Changing any source code will require regenerating
# the zip file ... this can be accomplished via:
#
# 'terraform apply -target=<module name>.random_id.source'
#
# In the event that you are uanble to regenerate the ZIP, it is sometimes necessary
# to "taint" the state via the following command:
#
# 'terraform taint -module=<module name> random_id.source'
#
# The generated lambda ARN is available via the module output '<module name>.lambda_arn'

# To enable IAM role reuse, it is required
# that any users of this module supply a ROLE ARN. Here is a bare bone example of
# an IAM role definition:

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Example 1: Generate a simple python lambda that has a single .py file with no
#            dependencies

module "example_lambda_1"
{
  source = "git::git@github.com:cargometrics/terraform//modules/resources/python_lambda?ref=v0.0.1"

  lambda_files       = ["lib/lambda_entry.py"]
  lambda_name        = "test lambda"
  lambda_entry       = "lambda_entry.foo"
  lambda_description = "my description"
  lambda_role_arn    = "${var.aws_iam_role.iam_for_lambda}"
}

# Example 2: Generate a python lambda that depends on auxilliary files

module "example_lambda_2"
{
  source = "git::git@github.com:cargometrics/terraform//modules/resources/python_lambda?ref=v0.0.1"

  lambda_files       = ["lib/helper1.py", "lib/helper2.py", "lib/lambda_entry.py"]
  lambda_name        = "test lambda"
  lambda_entry       = "lambda_entry.foo"
  lambda_description = "my description"
  lambda_role_arn    = "${var.aws_iam_role.iam_for_lambda}"
}

# Example 3: Generate a python lambda that has dependencies on the python 'request'
#            package

module "example_lambda_3"
{
  source = "git::git@github.com:cargometrics/terraform//modules/resources/python_lambda?ref=v0.0.1"

  lambda_files       = ["lib/lambda_entry.py"]
  lambda_name        = "test lambda"
  lambda_entry       = "lambda_entry.foo"
  lambda_description = "my description"
  lambda_role_arn    = "${var.aws_iam_role.iam_for_lambda}"

  package_requirements = "lib/requirements.txt"
}