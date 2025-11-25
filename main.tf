# Backend Buckets for Cloud Storage
resource "google_compute_backend_bucket" "this" {
  for_each = var.backend_buckets

  project     = var.project_id
  name        = each.value.name
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn

  dynamic "cdn_policy" {
    for_each = each.value.cdn_policy != null ? [each.value.cdn_policy] : []
    content {
      cache_mode        = cdn_policy.value.cache_mode
      client_ttl        = cdn_policy.value.client_ttl
      default_ttl       = cdn_policy.value.default_ttl
      max_ttl           = cdn_policy.value.max_ttl
      negative_caching  = cdn_policy.value.negative_caching
      serve_while_stale = cdn_policy.value.serve_while_stale

      dynamic "negative_caching_policy" {
        for_each = cdn_policy.value.negative_caching_policy != null ? cdn_policy.value.negative_caching_policy : []
        content {
          code = negative_caching_policy.value.code
          ttl  = negative_caching_policy.value.ttl
        }
      }

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_http_headers   = cache_key_policy.value.include_http_headers
          query_string_whitelist = cache_key_policy.value.query_string_whitelist
        }
      }
    }
  }

  custom_response_headers = each.value.custom_response_headers
}

# Global URL Map
resource "google_compute_url_map" "this" {
  project         = var.project_id
  name            = var.url_map_name
  default_service = var.backends

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_matchers
    content {
      name            = path_matcher.value.name
      default_service = path_matcher.value.default_service

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.service
        }
      }
    }
  }
}

# Create Global Static IPs
resource "google_compute_global_address" "this" {
  for_each = var.forwarding_rules

  project    = var.project_id
  name       = each.value.ip_name != null ? each.value.ip_name : "${each.value.name}-ip"
  ip_version = each.value.ip_version
  address    = each.value.ip_address
}

# Create Target HTTP Proxies
resource "google_compute_target_http_proxy" "this" {
  for_each = var.backend_protocol == "HTTP" ? var.forwarding_rules : {}
  
  project = var.project_id
  name    = each.value.proxy_name != null ? each.value.proxy_name : "${each.value.name}-proxy"
  url_map = google_compute_url_map.this.id
}

# Create Target HTTPS Proxies
resource "google_compute_target_https_proxy" "this" {
  for_each = var.backend_protocol == "HTTPS" ? var.forwarding_rules : {}
  
  project          = var.project_id
  name             = each.value.proxy_name != null ? each.value.proxy_name : "${each.value.name}-proxy"
  url_map          = google_compute_url_map.this.id
  ssl_certificates = each.value.ssl_certificates
}

# Create Global Forwarding Rules
resource "google_compute_global_forwarding_rule" "this" {
  for_each = var.forwarding_rules

  project               = var.project_id
  name                  = each.value.name
  ip_protocol           = "TCP"
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = each.value.port_range
  ip_address            = google_compute_global_address.this[each.key].address
  
  target = var.backend_protocol == "HTTP" ? (
    google_compute_target_http_proxy.this[each.key].id
  ) : (
    google_compute_target_https_proxy.this[each.key].id
  )
  
  depends_on = [
    google_compute_target_http_proxy.this,
    google_compute_target_https_proxy.this,
    google_compute_global_address.this
  ]
}