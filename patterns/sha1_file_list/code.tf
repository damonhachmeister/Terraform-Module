# Creates a holder for the sha1 of each file in 'lambda_files'
data "template_file" "all_file_sha1" {
  count = "${length(var.files)}"
  template = "${sha1(file(element(var.files, count.index)))}"
}

# Concatenates the sha1's above into a single string (':' seperated sha1's)
data "template_file" "concatenated_sha1" {
  template = "${join(":", data.template_file.all_file_sha1.*.template)}"
}

output "sha1" { value = "${data.template_file.concatenated_sha1.template}" }