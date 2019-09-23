variable "project" {
  default = "api"
}

variable "host_project_id" {
  default = "root-b50404e3"
}

variable "host_vpc_name" {
  default = "example-vpc-host"
}

variable "vpc" {
  default = {
    public_subnet_cidr = {
      dev  = "10.128.0.0/16"
      prod = "10.1.0.0/24"
    }
    private_subnet_cidr = {
      dev  = "10.129.0.0/16"
      prod = "10.1.1.0/24"
    }
    k8s_pods_cidr = {
      dev  = "10.130.0.0/16"
      prod = "10.131.0.0/16"
    }
    k8s_services_cidr = {
      dev  = "10.131.0.0/16"
      prod = "10.132.0.0/16"
    }
    k8s_pods_range_name     = "secondary-range-pods"
    k8s_services_range_name = "secondary-range-services"
  }
}

variable "sql" {
  default = {
    tier = {
      dev  = "db-f1-micro"
      prod = "db-n1-standard-1"
    }
    availability_type = {
      dev  = "REGIONAL"
      prod = "ZONAL"
    }
  }
}

variable "k8s" {
  default = {
    machine_type = {
      dev  = "g1-small"
      prod = "n1-standard-1"
    }
    preemptible = {
      dev  = true
      prod = false
    }
  }
}



