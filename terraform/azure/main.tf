provider "azurerm" {
  subscription_id = var.subscription_id 
  features {}
  
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}


###
#Creo resourcegroup
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-prueba"
  location = var.location
  tags = var.tags
}

