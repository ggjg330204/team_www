# 06_lets_encrypt.tf (수정됨: Self-Signed 인증서 사용)

# Key Vault 자체 기능을 이용해 인증서를 생성합니다.
# 외부(Let's Encrypt) 통신이 없으므로 MSI/권한 오류가 발생하지 않습니다.
resource "azurerm_key_vault_certificate" "ssl_cert" {
  name         = "www-ssl-cert"
  key_vault_id = module.security.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self" # Self-Signed (자체 서명) 설정
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
      subject            = "CN=www.04www.cloud"
      validity_in_months = 12
      
      subject_alternative_names {
        dns_names = ["www.04www.cloud", "04www.cloud"]
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
        "1.3.6.1.5.5.7.3.1", # Server Authentication
      ]
    }
  }
}