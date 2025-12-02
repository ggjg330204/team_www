#source\data.tf
module "source" {
  source = "./modules/source"

  subid = "99b79efe-ebd6-468c-b39f-5669acb259e1"

  ###############수정 필요 (개인 or 팀)###################
  #### 사용할때 예시 : name =  "${var.teamuser}-nat"   ###
  #rgname = "04-T1-ghlee3"
  rgname = "04-T1-www"
  #teamuser = "ghlee3"
  teamuser = "www"

  loca   = "KoreaCentral"

  vnet-bas  = "10.0.0.0/24"
  vnet-nat  = "10.0.1.0/24"
  vnet-load = "10.0.2.0/24"
  vnet-web1 = "10.0.3.0/24"
  vnet-web2 = "10.0.4.0/24"
  vnet-db   = "10.0.5.0/24"
  vnet-vmss = "192.168.0.0/24"
}