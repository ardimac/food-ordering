packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-testapp-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "ap-southeast-1"
  source_ami    = "ami-047126e50991d067b"
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "script.sh"  # Replace with your actual script file
    destination = "/tmp/script.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh"
    ]
  }
}
