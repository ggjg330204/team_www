module "network" {
  source = "./modules/Network"

  rgname    = var.rg_name
  loca      = var.location
  teamuser  = var.teamuser
  subid     = "unused" # Not used in module
  vnet-bas  = "${var.teamuser}-vnet"
  vnet-nat  = "${var.teamuser}-vnet"
  vnet-load = "${var.teamuser}-vnet"
  vnet-web1 = "${var.teamuser}-vnet"
  vnet-web2 = "${var.teamuser}-vnet"
  vnet-db   = "${var.teamuser}-vnet"
  vnet-vmss = "${var.teamuser}-vnet"
}

module "compute" {
  source = "./modules/Compute"

  # Compute module seems to share variables with Network or has similar structure
  # Checking 100_var.tf in Compute (it was copied from source/100_var.tf)
  # It likely needs the same inputs
  rgname    = var.rg_name
  loca      = var.location
  teamuser  = var.teamuser
  subid     = "unused"
  vnet-bas  = "${var.teamuser}-vnet"
  vnet-nat  = "${var.teamuser}-vnet"
  vnet-load = "${var.teamuser}-vnet"
  vnet-web1 = "${var.teamuser}-vnet"
  vnet-web2 = "${var.teamuser}-vnet"
  vnet-db   = "${var.teamuser}-vnet"
  vnet-vmss = "${var.teamuser}-vnet"
  nic_id    = module.network.nic_id
}

module "storage" {
  source = "./modules/storage"

  rgname = var.rg_name
  loca   = var.location
}

module "db" {
  source = "./modules/database"

  rgname       = var.rg_name
  loca         = var.location
  db_subnet_id = module.network.subnet_id
  db_password  = var.db_password
}
