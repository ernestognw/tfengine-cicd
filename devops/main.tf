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

# This folder contains Terraform resources to setup the devops project, which includes:
# - The project itself,
# - APIs to enable,
# - Deletion lien,
# - Project level IAM permissions for the project owners,
# - A Cloud Storage bucket to store Terraform states for all deployments,
# - Admin permission at folder level,
# - Cloud Identity groups and memberships, if requested.

// TODO: replace with https://github.com/terraform-google-modules/terraform-google-bootstrap
terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "cicd-test-state"
    prefix = "devops"
  }
}

# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = "cicd-test-devops"
}

# Create the project, enable APIs, and create the deletion lien, if specified.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.2.2"

  name            = "cicd-test-devops"
  org_id          = ""
  folder_id       = "526868020083"
  billing_account = "01C1BA-DBC5AE-2AF7A4"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  activate_apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
  ]
}

# Terraform state bucket, hosted in the devops project.
module "state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "cicd-test-state"
  project_id = module.project.project_id
  location   = "us-central1"
}

# Devops project owners group.
module "owners_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id           = "cicd-test-devops-owners@qrispier.com"
  customer_id  = "C03yezfd5"
  display_name = "cicd-test-devops-owners"
  owners       = ["ernestognw@qrispier.com"]
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "owners_wait" {
  depends_on = [
    module.owners_group,
  ]
  create_duration = "15s"
}

# Project level IAM permissions for devops project owners.
resource "google_project_iam_binding" "devops_owners" {
  project    = module.project.project_id
  role       = "roles/owner"
  members    = ["group:${module.owners_group.id}"]
  depends_on = [time_sleep.owners_wait]
}

# Admins group for at folder level.
module "admins_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id           = "cicd-test-org-admins@qrispier.com"
  customer_id  = "C03yezfd5"
  display_name = "cicd-test-org-admins"
  owners       = ["ernestognw@qrispier.com"]
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "admins_wait" {
  depends_on = [
    module.admins_group,
  ]
  create_duration = "15s"
}

# Admin permission at folder level.
resource "google_folder_iam_member" "admin" {
  folder     = "folders/526868020083"
  role       = "roles/resourcemanager.folderAdmin"
  member     = "group:${module.admins_group.id}"
  depends_on = [time_sleep.admins_wait]
}
