# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
    kubernetes  = "~> 1.0"
  }
  backend "gcs" {
    bucket = "cicd-test-state"
    prefix = "groups"
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 10.2.2"

  project_id    = "cicd-test"
  activate_apis = []
}
# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = module.project.project_id
}


module "cicd_test_cicd_viewers_qrispier_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id           = "cicd-test-cicd-viewers@qrispier.com"
  customer_id  = "C03yezfd5"
  display_name = "cicd-test-cicd-viewers"
  owners       = ["ernestognw@qrispier.com"]
}

module "cicd_test_cicd_editors_qrispier_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id           = "cicd-test-cicd-editors@qrispier.com"
  customer_id  = "C03yezfd5"
  display_name = "cicd-test-cicd-editors"
  owners       = ["ernestognw@qrispier.com"]
}
