terraform {
  cloud {
    organization = "amyzanje"

    workspaces {
      name = "vpconly"
    }
  }
}
