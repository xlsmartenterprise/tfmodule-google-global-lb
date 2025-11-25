variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources."
  type        = string
}

variable "load_balancing_scheme" {
  description = "Load balancing scheme (EXTERNAL or EXTERNAL_MANAGED)"
  type        = string
  default     = "EXTERNAL_MANAGED"
}

variable "backend_protocol" {
  description = "Protocol for the backend service (HTTP or HTTPS)"
  type        = string
}

variable "url_map_name" {
  description = "Name of the URL map"
  type        = string
}

variable "backends" {
  description = "The backend service URL for the URL map's default service"
  type        = string
}

variable "backend_buckets" {
  description = "Map of backend buckets for Cloud Storage"
  type = map(object({
    name                    = string
    bucket_name             = string
    description             = optional(string)
    enable_cdn              = optional(bool, false)
    custom_response_headers = optional(list(string), [])
    cdn_policy = optional(object({
      cache_mode        = optional(string, "CACHE_ALL_STATIC")
      client_ttl        = optional(number, 3600)
      default_ttl       = optional(number, 3600)
      max_ttl           = optional(number, 86400)
      negative_caching  = optional(bool, false)
      serve_while_stale = optional(number, 0)
      negative_caching_policy = optional(list(object({
        code = number
        ttl  = optional(number)
      })))
      cache_key_policy = optional(object({
        include_http_headers   = optional(list(string))
        query_string_whitelist = optional(list(string))
      }))
    }))
  }))
  default = {}
}

variable "host_rules" {
  description = "List of host rules for URL map"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_matchers" {
  description = "List of path matchers for URL map"
  type = list(object({
    name            = string
    default_service = string
    path_rules = optional(list(object({
      paths   = list(string)
      service = string
    })), [])
  }))
  default = []
}

variable "forwarding_rules" {
  description = "Map of forwarding rules with different IPs and SSL certificates"
  type = map(object({
    name              = string
    ip_name           = optional(string)
    ip_address        = optional(string)
    port_range        = string
    ssl_certificates  = list(string)
    ip_version        = optional(string, "IPV4")
    proxy_name        = optional(string)
  }))
}