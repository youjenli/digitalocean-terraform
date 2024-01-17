locals {
  cluster_name = "kubernetes-cluster-playground"
}

resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name   = local.cluster_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.28.2-do.0"
  destroy_all_associated_resources = true
  registry_integration = true

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb-amd"
    node_count = 3

    taint {
      key    = "workloadKind"
      value  = "database"
      effect = "NoSchedule"
    }
  }

  depends_on = [
    digitalocean_container_registry.registry
  ]
}

data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = local.cluster_name
  depends_on = [
    digitalocean_kubernetes_cluster.k8s_cluster
  ]
}

resource "local_file" "kubeconfig" {
  depends_on = [data.digitalocean_kubernetes_cluster.k8s_cluster]
  content    = data.digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].raw_config
  filename   = "${var.kubeconfig_path}/.kubeconfig"
}