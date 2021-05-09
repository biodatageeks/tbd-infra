resource "helm_release" "nginx-ingress" {
  name = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart = "nginx-ingress"
  version = var.nginx_ingress_version
  namespace = "default"
  create_namespace = true
  atomic = true
  wait = true
  timeout = 3600

  values = [
    file("${path.module}/resources/values-nginx.yaml")
  ]
}

resource "helm_release" "cert-manager" {
  depends_on = [helm_release.nginx-ingress]
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = var.cert_manager_version
  namespace = "default"
  create_namespace = true
  atomic = true
  wait = true
  timeout = 3600

  values = [
    file("${path.module}/resources/values-cert-manager.yaml")
  ]
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "kubectl_manifest" "issuer-letsencrypt" {
  depends_on = [helm_release.cert-manager]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt
  namespace: default
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.acme_email}
    privateKeySecretRef:
      name: account-key
    solvers:
    - http01:
       ingress:
         class: nginx
YAML
}


resource "kubectl_manifest" "grafana-certificate" {
  depends_on = [helm_release.cert-manager]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-cert
  namespace: default
spec:
  secretName: grafana-certificate
  issuerRef:
    name: letsencrypt
  dnsNames:
  - ${var.grafana_host}
YAML
}

resource "kubectl_manifest" "prometheus-certificate" {
  depends_on = [helm_release.cert-manager]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: prometheus-cert
  namespace: default
spec:
  secretName: prometheus-certificate
  issuerRef:
    name: letsencrypt
  dnsNames:
  - ${var.prometheus_host}
YAML
}




resource "kubectl_manifest" "ingress-grafana" {
  depends_on = [helm_release.cert-manager, helm_release.nginx-ingress]
  yaml_body = <<YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-grafana
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: letsencrypt
    acme.cert-manager.io/http01-edit-in-place: "true"
    nginx.ingress.kubernetes.io/from-to-www-redirect: "true"
    cert-manager.io/issue-temporary-certificate: "false"
    nginx.ingress.kubernetes.io/permanent-redirect: https://${var.grafana_host}
spec:
  tls:
  - hosts:
    - ${var.grafana_host}
    secretName: grafana-certificate
  rules:
    - host: ${var.grafana_host}
      http:
        paths:
          - path: /
            backend:
              serviceName: prometheus-community-grafana
              servicePort: 80
YAML
}

resource "kubectl_manifest" "ingress-prometheus" {
  depends_on = [helm_release.cert-manager, helm_release.nginx-ingress]
  yaml_body = <<YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingressrule-prometheus
  annotations:
    kubernetes.io/ingress.class: "nginx"
    acme.cert-manager.io/http01-edit-in-place: "true"
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/from-to-www-redirect: "true"
    cert-manager.io/issue-temporary-certificate: "false"
    nginx.ingress.kubernetes.io/permanent-redirect: https://${var.prometheus_host}
spec:
  tls:
  - hosts:
    - ${var.prometheus_host}
    secretName: prometheus-certificate
  rules:
    - host: ${var.prometheus_host}
      http:
        paths:
          - path: /
            backend:
              serviceName: prometheus-community-kube-prometheus
              servicePort: 9090
YAML
}
