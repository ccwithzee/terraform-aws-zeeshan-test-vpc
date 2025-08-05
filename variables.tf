variable "vpc_config" {

    description = "To get Cidr and name of VPC form user"
    type = object({
      cidr_block = string
      name = string 
    })

    validation {
      condition = can(cidrnetmask(var.vpc_config.cidr_block))
      error_message = "Invalid cidr format -${var.vpc_config.cidr_block}"
    }
}

variable "subnet_config" {

    description = "get the cidr and az for the subnets"
    type = map(object({
      cidr_block = string
      az = string  #availbilty zones 
      public = optional(bool, false) #false is treated as default
    }))

    
    validation {

        #for this we make as suppsoe we have 3 subnets 2 are true and another is in wrong format 
      condition = alltrue([for config in var.subnet_config: can(cidrnetmask(config.cidr_block))])#all ture means all the value must be true
      error_message = "Invalid cidr format -${var.vpc_config.cidr_block}"
    }
}

