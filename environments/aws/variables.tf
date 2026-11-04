variable "aws_region" {
  description = "Región de AWS para el provider."
  type        = string
}

variable "name" {
  description = "Nombre de la VPC y prefijo para sus recursos."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC, que contiene la subnet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Bloque CIDR de la subnet, dentro de vpc_cidr."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Zona de disponibilidad; null permite que AWS seleccione una."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Etiquetas adicionales para los recursos."
  type        = map(string)
  default     = {}
}
