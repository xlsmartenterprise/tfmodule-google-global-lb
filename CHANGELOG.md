# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.2] - 2026-09-13

### Added
- Automatic HTTP to HTTPS redirection support via `enable_http_to_https_redirect` variable

## [v1.0.1] - 2026-09-13

### Added
- Global SSL Policy support for target HTTPS proxies via `ssl_policy` module input variable
- Per-forwarding-rule SSL policy override support in `forwarding_rules` configuration (`ssl_policy = optional(string)`)
- Documentation and example for HTTPS load balancer with SSL policy in `README.md`

## [v1.0.0] - 2025-11-25

### Added

#### Features
- Initial release of the Google Cloud Global Load Balancer Terraform module
- Support for both HTTP and HTTPS load balancing configurations
- Backend bucket management with Cloud Storage integration
- CDN policy configuration with caching controls
- URL map management with host rules and path matchers
- Global static IP address allocation
- Target HTTP/HTTPS proxy creation based on protocol
- Global forwarding rules configuration
- Support for multiple forwarding rules with different IPs and SSL certificates
- Comprehensive CDN policy options including:
  - Cache mode configuration
  - TTL settings (client, default, max)
  - Negative caching policies
  - Cache key policy with HTTP headers and query string whitelist
- Custom response headers support for backend buckets

#### Outputs
- `url_map_id` - The ID of the URL map
- `url_map_self_link` - The self_link of the URL map
- `backend_buckets` - Map of backend bucket details
- `forwarding_rules` - Map of forwarding rule details
- `ip_addresses` - Map of static IP addresses

#### Requirements
- Terraform >= 1.5.0
- Google Provider >= 7.0.0, < 8.0.0
- Google Beta Provider >= 7.0.0, < 8.0.0