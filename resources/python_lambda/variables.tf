# ------------------
# REQUIRED VARIABLES
# ------------------

variable "lambda_files" {
  type        = "list"
  description = "List of files that should be included in your lambda.\n
These should contain relative paths (i.e. ['lib/mylambda.py'])"
}


variable "lambda_name" {
  type        = "string"
  description = "Unique name for the generated lambda"
}

variable "lambda_description" {
  type        = "string"
  description = "Meaningful description for what this lambda does"
}

variable "lambda_role_arn" {
  type        = "string"
  description = "AWS role that should be attached to this lambda"
}

variable "lambda_entry" {
  type        = "string"
  description = "Entrypoint for the lambda (e.g. <filename>.<method name>"
}

# ------------------
# OPTIONAL VARIABLES
# ------------------

variable "lambda_timeout" {
  type        = "string"
  default     = "3"
  description = "Time (in seconds) that this lambda should execute before timing out"
}
  
variable "zip_output_directory" {
  type = "string"
  default = "dist"
  description = "Relative path to an output directory where the generated lambda\n
zip should be placed"
}

variable "lambda_runtime" {
  type    = "string"
  default = "python2.7"
}

variable "lambda_memory_size" {
  type = "string"
  default = "128"
}

variable "subnet_ids" {
  type = "list"
  default = []
}

variable "security_group_ids" {
  type = "list"
  default = []
}

variable "top_level_python_folder" {
  type = "string"
  default = "lib"
  description = "Relative path to the top-level folder containing python sources."
}

variable "package_requirements" {
  type = "string"
  default =  ""
  description = "If your lambda needs packages available at execution time, supply\n
a requirements file and those packages will be included in the lambda ZIP"
}

