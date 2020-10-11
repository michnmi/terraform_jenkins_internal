terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

provider "libvirt" {
  alias = "vmhost01"
  uri   = "qemu+ssh://jenkins_automation@vmhost01/system?keyfile=../id_ed25519_jenkins"
  // uri   = "qemu+ssh://vmhost01/system"

}

variable "env" {
  type = string
}

resource "libvirt_volume" "jenkins" {
  provider         = libvirt.vmhost01
  name             = "jenkins-${var.env}.qcow2"
  pool             = var.env
  base_volume_name = "jenkins_base.qcow2"
  format           = "qcow2"
  base_volume_pool = var.env
}

resource "libvirt_domain" "jenkins" {
  provider  = libvirt.vmhost01
  name      = "jenkins-${var.env}"
  memory    = "1536"
  vcpu      = 1
  autostart = true

  // The MAC here is given an IP through mikrotik
  network_interface {
    macvtap  = "enp0s25"
    mac      = "52:54:00:EA:17:55"
    hostname = "jenkins-${var.env}"
  }

  network_interface {
    // network_id = libvirt_network.default.id
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.jenkins.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
  }

}
