terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://10.0.0.10:8006/api2/json"
  pm_api_token_id = "terraform-prov@pve!terraform_token"
  pm_api_token_secret = "d4e4e26c-71b8-46b7-b73f-1ffa77e1d4fb"
  pm_tls_insecure = true
}

resource "proxmox_lxc" "basic" {
  target_node  = "proxmox"
  hostname     = "piehole"
  ostemplate   = "iso:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.root_password
  start = true
  unprivileged = true
  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9J49LUQzLf372SOXRlvvUlvpug1VZtQK8WgxTQJwiB svedberg.tobias@gmail.com
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhmcyNsZB+q4m10minsPJ7FWzPfBZ+cPrm/lMTklPHM Arch@SENORL0017
  EOT

  rootfs {
    storage = "ssd"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = var.net_cidr
    gw     = var.net_gw
  }

# Post creation
  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      private_key = "${file("~/.ssh/id_ed25519")}"
      host     = regex("(.*)/.*", "${var.net_cidr}")[0]
    }
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      private_key = "${file("~/.ssh/id_ed25519")}"
      host     = regex("(.*)/.*", "${var.net_cidr}")[0]
    }
    source      = "dnsrecords.list"
    destination = "/tmp/custom.list"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      private_key = "${file("~/.ssh/id_ed25519")}"
      host     = regex("(.*)/.*", "${var.net_cidr}")[0]
    }
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh ${var.pihole_pass}"
    ]
  }
}