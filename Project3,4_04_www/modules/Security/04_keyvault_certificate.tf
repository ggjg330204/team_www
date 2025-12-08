
resource "azurerm_key_vault_certificate" "ssl_cert" {
  name         = "www-ssl-cert"
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject            = "CN=www.${var.domain_name}"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = ["www.${var.domain_name}", "mail.${var.domain_name}", var.domain_name]
      }

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyEncipherment",
        "keyAgreement",
        "keyCertSign",
      ]

      extended_key_usage = [
        "1.3.6.1.5.5.7.3.1",
      ]
    }
  }
}
