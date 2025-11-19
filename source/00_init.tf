terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "=4.52.0"
        }
    }
}

provider "azurerm" {
    features {
        resource_group {
            prevent_deletion_if_contains_resources = false
        }
    }
    subscription_id = var.subid
}

#klasjdflkajsdlkfjasdfsadfasdfsadf


##fepwqjfepjwfejwpefjpjpo



1471274172r309fjwsdiofh9uwfdgv98w2ujf9-2wh4fe9h9
