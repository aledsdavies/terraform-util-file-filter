terraform {
  // We are using the validation functionality introduced in terraform 0.13
  required_version = ">= 0.13"
}

locals {
  // This value fetches all the files in the build dir. We use this as a separate local so we don't have to run
  // the fileset function each time in the loop below
  filesList = fileset(var.base_dir, "**")

  /**
    This loop generates a map of the files form found in fileList.

    It also merges all the values form the file_filters variable allowing you to use the output of this
    module directly in a for_each in the resource.
  */
  files = {
  for each in flatten([for key, val in var.filters : [
  for path in local.filesList :
  merge({
    // Gives the file name without the path
    file_name: element(split("/", path), length(split("/", path))-1)
    // Gives the path without the file_src
    path : path
    // Gives the location on the disk
    src : "${var.base_dir}/${path}"
  }, val)
  if length(regexall(val.regex, path)) > 0
  ]]) :

  each.path => each
  }
}