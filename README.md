# tfmodule-google-global-load-balancer

Terraform module for creating and managing Google Cloud Global Load Balancers with support for HTTP/HTTPS traffic, CDN integration, and Cloud Storage backend buckets.

## Features

- **Multi-Protocol Support**: Configure HTTP or HTTPS load balancing based on your requirements
- **Backend Bucket Integration**: Serve static content directly from Cloud Storage buckets
- **CDN Configuration**: Advanced CDN policies with caching controls and optimization
- **URL Mapping**: Flexible URL routing with host rules and path matchers
- **SSL Support**: HTTPS configuration with multiple SSL certificates
- **Static IP Management**: Automatic allocation and management of global static IPs
- **Multiple Forwarding Rules**: Support for multiple frontend configurations
- **Custom Headers**: Add custom response headers to backend buckets

## Usage

### Basic Example
```hcl
module "global_lb" {
  source = "./modules/global-load-balancer"

  project_id            = "my-project-id"
  name                  = "my-global-lb"
  backend_protocol      = "HTTPS"
  url_map_name          = "my-url-map"
  backends              = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendServices/my-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  forwarding_rules = {
    main = {
      name             = "my-global-lb-frontend"
      port_range       = "443"
      ssl_certificates = ["projects/my-project/global/sslCertificates/my-cert"]
    }
  }
}
```

### Advanced Example with Backend Buckets and CDN
```hcl
module "global_lb_with_cdn" {
  source = "./modules/global-load-balancer"

  project_id            = "my-project-id"
  name                  = "cdn-global-lb"
  backend_protocol      = "HTTPS"
  url_map_name          = "cdn-url-map"
  backends              = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendBuckets/static-bucket"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # Backend buckets for static content
  backend_buckets = {
    static_content = {
      name        = "static-content-bucket"
      bucket_name = "my-static-content-bucket"
      description = "Backend bucket for static assets"
      enable_cdn  = true
      
      cdn_policy = {
        cache_mode        = "CACHE_ALL_STATIC"
        client_ttl        = 3600
        default_ttl       = 7200
        max_ttl          = 86400
        negative_caching  = true
        serve_while_stale = 86400
        
        negative_caching_policy = [
          {
            code = 404
            ttl  = 300
          },
          {
            code = 410
            ttl  = 900
          }
        ]
        
        cache_key_policy = {
          include_http_headers   = ["Accept-Language", "Accept-Encoding"]
          query_string_whitelist = ["version", "locale"]
        }
      }
      
      custom_response_headers = [
        "X-Cache-Status: {cdn_cache_status}",
        "X-CDN-Geo: {client_region}"
      ]
    }
  }

  # URL routing configuration
  host_rules = [
    {
      hosts        = ["example.com", "www.example.com"]
      path_matcher = "main-paths"
    },
    {
      hosts        = ["api.example.com"]
      path_matcher = "api-paths"
    }
  ]

  path_matchers = [
    {
      name            = "main-paths"
      default_service = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendServices/main-backend"
      
      path_rules = [
        {
          paths   = ["/static/*", "/assets/*"]
          service = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendBuckets/static-bucket"
        },
        {
          paths   = ["/api/*"]
          service = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendServices/api-backend"
        }
      ]
    },
    {
      name            = "api-paths"
      default_service = "https://www.googleapis.com/compute/v1/projects/my-project/global/backendServices/api-backend"
    }
  ]

  # Multiple forwarding rules for different domains
  forwarding_rules = {
    primary = {
      name             = "cdn-lb-frontend-primary"
      ip_name          = "cdn-lb-ip-primary"
      port_range       = "443"
      ssl_certificates = ["projects/my-project/global/sslCertificates/example-com-cert"]
      ip_version       = "IPV4"
    },
    secondary = {
      name             = "cdn-lb-frontend-secondary"
      ip_name          = "cdn-lb-ip-secondary"
      port_range       = "443"
      ssl_certificates = ["projects/my-project/global/sslCertificates/api-example-com-cert"]
      ip_version       = "IPV4"
    }
  }
}
```

## Inputs

| Name | Type | Description | Default | Required |
|------|------|-------------|---------|:--------:|
| project_id | `string` | The GCP project ID | n/a | yes |
| name | `string` | Name for the forwarding rule and prefix for supporting resources | n/a | yes |
| load_balancing_scheme | `string` | Load balancing scheme (EXTERNAL or EXTERNAL_MANAGED) | `"EXTERNAL_MANAGED"` | no |
| backend_protocol | `string` | Protocol for the backend service (HTTP or HTTPS) | n/a | yes |
| url_map_name | `string` | Name of the URL map | n/a | yes |
| backends | `string` | The backend service URL for the URL map's default service | n/a | yes |
| backend_buckets | `map(object)` | Map of backend buckets for Cloud Storage | `{}` | no |
| host_rules | `list(object)` | List of host rules for URL map | `[]` | no |
| path_matchers | `list(object)` | List of path matchers for URL map | `[]` | no |
| forwarding_rules | `map(object)` | Map of forwarding rules with different IPs and SSL certificates | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| url_map_id | The ID of the URL map |
| url_map_self_link | The self_link of the URL map |
| backend_buckets | Map of backend bucket details including ID, self_link, name, and bucket_name |
| forwarding_rules | Map of forwarding rule details including ID, self_link, and IP address |
| ip_addresses | Map of static IP addresses allocated for the forwarding rules |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| google | >= 7.0.0, < 8.0.0 |
| google-beta | >= 7.0.0, < 8.0.0 |

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and changes.