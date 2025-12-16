resource "azurerm_public_ip" "fw_pip" {
  name                = "hub-fw-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]
  tags = {
    Environment = "Production"
    Purpose     = "Firewall-PIP"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes        = [zones, tags]
  }
}
resource "azurerm_firewall" "hub_fw" {
  name                = "hub-firewall"
  location            = var.loca
  resource_group_name = var.rgname
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = ["1", "2"]
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
  tags = {
    Environment = "Production"
    Purpose     = "Hub-Firewall"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "hub-fw-policy"
  resource_group_name = var.rgname
  location            = var.loca
}
resource "azurerm_firewall_policy_rule_collection_group" "fw_policy_rcg" {
  name               = "hub-fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100
  application_rule_collection {
    name     = "app_rules"
    priority = 100
    action   = "Allow"
    rule {
      name = "Allow-Windows-Update"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.update.microsoft.com", "*.windowsupdate.com", "packages.microsoft.com", "acs-mirror.azureedge.net"]
    }
    rule {
      name = "Allow-Package-Repos"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = [
        "*.rockylinux.org", "download.rockylinux.org",
        "*.remirepo.net", "rpms.remirepo.net", "cdn.remirepo.net",
        "*.fedoraproject.org", "mirrors.fedoraproject.org", "dl.fedoraproject.org",
        "*.ubuntu.com", "security.ubuntu.com", "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com", "ppa.launchpadcontent.net",
        "*.centos.org", "mirror.centos.org", "vault.centos.org",
        "*.cloudflare.com", "*.akamai.net", "*.fastly.net", "*.amazonaws.com",
        "mirror.kakao.com", "*.kakao.com", "ftp.kaist.ac.kr", "ftp.jaist.ac.jp",
        "*.ac.jp", "*.ac.kr", "*.edu.cn", "*.riken.jp"
      ]
    }
    rule {
      name = "Allow-Dev-Tools"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = [
        "github.com", "*.github.com", 
        "objects.githubusercontent.com", "raw.githubusercontent.com",
        "*.githubassets.com", "github-releases.githubusercontent.com",
        "github-cloud.s3.amazonaws.com", "*.s3.amazonaws.com",
        "release-assets.githubusercontent.com", "*.githubusercontent.com",
        "*.digicert.com", "cacerts.digicert.com",
        "*.jsdelivr.net", "cdn.jsdelivr.net",
        "*.unsplash.com", "images.unsplash.com",
        "packages.microsoft.com", "*.microsoft.com"
      ]
    }
    rule {
      name = "Allow-Azure-Services"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["management.azure.com", "login.microsoftonline.com", "graph.microsoft.com"]
    }
    rule {
      name = "Allow-Misc-Services"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = [
        "api.snapcraft.io", "*.snapcraft.io", 
        "*.letsencrypt.org", "zerossl.com", "acme-v02.api.letsencrypt.org",
        "fonts.googleapis.com", "fonts.gstatic.com",
        "get.acme.sh", "*.acme.sh"
      ]
    }
  }
  network_rule_collection {
    name     = "network_rules"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "Allow-DNS"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "Allow-NTP"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
    rule {
      name                  = "Allow-MySQL"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["3306"]
    }
    rule {
      name                  = "Allow-Redis"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["6379", "6380"]
    }
  }
}
