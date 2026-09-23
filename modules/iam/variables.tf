variable "role_name" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "trusted_services" {
  type = list(string)
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}