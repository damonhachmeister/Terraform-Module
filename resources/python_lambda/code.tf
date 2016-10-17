# Creates a holder for the sha1 of each file in 'lambda_files'
data "template_file" "all_file_sha1" {
  count = "${length(var.lambda_files)}"
  template = "${sha1(file(element(var.lambda_files, count.index)))}"
}

# Concatenates the sha1's above into a single string (':' seperated sha1's)
data "template_file" "concatenated_sha1" {
  template = "${join(":", data.template_file.all_file_sha1.*.template)}"
}

resource "null_resource" "install_packages" {  
  provisioner "local-exec" {
    command = <<EOF
       if [[ -z ${var.package_requirements} ]]; then
         echo Retrieving package dependencies
         docker pull lambci/lambda:build-python2.7
         docker run -t --rm -v `pwd`/${var.top_level_python_folder}:/root/${var.lambda_name} lambci/lambda:build-python2.7 pip install -t /root/${var.lambda_name} -r ${var.package_requirements}
       fi
    EOF
  }
}

# This will detect when the source code for the lambda has changed,
# by using a checksum of the files as the "keeper" for the random resource.
# On a change, it will build the zip archive with our lambda module,
# named in part for the checksum.
resource "random_id" "source" {
  depends_on = ["null_resource.install_packages"]
  
  keepers = {     
      hash = "${sha1(data.template_file.concatenated_sha1.template)}"
  }

  byte_length = 8

  provisioner "local-exec" {
    command = <<EOF
echo Building the lambda zip archive
if [ ! -d ${var.zip_output_directory} ]; then
  mkdir ${var.zip_output_directory}
fi

zip ${var.zip_output_directory}/${replace(var.lambda_name, " ", "_")}-${self.keepers.hash}.zip ${join(" ", var.lambda_files)}
EOF
  }
}

resource "aws_lambda_function" "lambda" {
    depends_on       = ["random_id.source"]
    filename         = "${var.zip_output_directory}/${replace(var.lambda_name, " ", "_")}-${random_id.source.keepers.hash}.zip"
    function_name    = "${var.lambda_name}"
    description      = "${var.lambda_description}"
    role             = "${var.lambda_role_arn}"    
    handler          = "${var.lambda_entry}"

    # OPTIONAL
    timeout          = "${var.lambda_timeout}"
    source_code_hash = "${base64sha256(file(format("${var.zip_output_directory}/${replace(var.lambda_name, " ", "_")}-%s.zip", random_id.source.keepers.hash)))}"
    runtime          = "${var.lambda_runtime}"
    memory_size      = "${var.lambda_memory_size}"
    
    vpc_config {
        subnet_ids         = "${var.subnet_ids}"
        security_group_ids = "${var.security_group_ids}"
	       }
}

output "lambda_arn" { value = "${aws_lambda_function.lambda.arn}" }