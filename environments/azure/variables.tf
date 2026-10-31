variable "name" {
  description = "Nombre de la red virtual."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos que creará el módulo."
  type        = string
}

variable "location" {
  description = "Región de Azure para la red virtual."
  type        = string
}

variable "address_space" {
  description = "Espacios CIDR de la red virtual."
  type        = list(string)
}

variable "subnet_name" {
  description = "Nombre de la subred."
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Prefijos CIDR de la subred, dentro de address_space."
  type        = list(string)
}

variable "tags" {
  description = "Etiquetas para los recursos."
  type        = map(string)
  default     = {}
}