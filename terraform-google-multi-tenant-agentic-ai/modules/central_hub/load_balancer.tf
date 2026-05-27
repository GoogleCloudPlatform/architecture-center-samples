# =============================================================================
# 1. Backend Service (Your existing code)
# =============================================================================
resource "google_compute_backend_service" "frontend_backend" {
  project               = var.hub_project_id
  name                  = "frontend-portal-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  # Attaching the Cloud Armor security policy
  security_policy = google_compute_security_policy.security_policy.self_link
}

# =============================================================================
# 2. URL Map (Routes traffic to the backend)
# =============================================================================
resource "google_compute_url_map" "frontend_url_map" {
  project         = var.hub_project_id
  name            = "frontend-portal-url-map"
  description     = "URL map for the frontend portal load balancer"
  default_service = google_compute_backend_service.frontend_backend.id
}

# =============================================================================
# 3. Target HTTP Proxy (Connects the forwarding rule to the URL map)
# =============================================================================
resource "google_compute_target_http_proxy" "frontend_http_proxy" {
  project     = var.hub_project_id
  name        = "frontend-portal-http-proxy"
  description = "HTTP proxy for the frontend portal"
  url_map     = google_compute_url_map.frontend_url_map.id
}

# =============================================================================
# 4. Global Forwarding Rule (The public entry point / IP address listener)
# =============================================================================
resource "google_compute_global_forwarding_rule" "frontend_forwarding_rule" {
  project               = var.hub_project_id
  name                  = "frontend-portal-forwarding-rule"
  target                = google_compute_target_http_proxy.frontend_http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}