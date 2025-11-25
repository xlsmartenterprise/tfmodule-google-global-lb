output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.this.id
}

output "url_map_self_link" {
  description = "The self_link of the URL map"
  value       = google_compute_url_map.this.self_link
}

output "backend_buckets" {
  description = "Map of backend bucket details"
  value = {
    for k, v in google_compute_backend_bucket.this : k => {
      id         = v.id
      self_link  = v.self_link
      name       = v.name
      bucket_name = v.bucket_name
    }
  }
}

output "forwarding_rules" {
  description = "Map of forwarding rule self_links"
  value = {
    for k, v in google_compute_global_forwarding_rule.this : k => {
      id         = v.id
      self_link  = v.self_link
      ip_address = v.ip_address
    }
  }
}

output "ip_addresses" {
  description = "Map of static IP addresses"
  value = {
    for k, v in google_compute_global_address.this : k => v.address
  }
}