variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  description = "Ingress rules"

  type = map(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))

  default = {}
}

variable "egress_rules" {
  description = "Egress rules"

  type = map(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))

  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}