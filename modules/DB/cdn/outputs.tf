output "cdn_endpoint_hostname" {
  description = "The Hostname of the CDN Endpoint"
  value       = "https://${azurerm_cdn_endpoint.main.fqdn}"
}

/*
### 학습 포인트 (CDN Outputs)
- **cdn_endpoint_hostname**: 전 세계에 배포된 CDN의 접속 주소입니다. 이미지 링크를 이걸로 바꾸면 엄청 빨라집니다.
*/
