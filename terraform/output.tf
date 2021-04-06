output "s3_website_endpoint" {
  value = aws_s3_bucket.web_s3.website_endpoint
}

output "ns_servers" {
  value = data.aws_route53_zone.zone.name_servers
}