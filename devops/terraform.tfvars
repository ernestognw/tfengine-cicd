# Copyright 2021 Google LLC
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

admins_group = {
  customer_id  = "C03yezfd5"
  display_name = "cicd-project-test-org-admins"
  id           = "cicd-project-test-org-admins@qrispier.com"
  owners       = ["ernestognw@qrispier.com"]
}
billing_account = "01C1BA-DBC5AE-2AF7A4"
parent_id       = "526868020083"
project = {
  apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
  ]
  owners_group = {
    customer_id  = "C03yezfd5"
    display_name = "cicd-project-test-devops-owners"
    id           = "cicd-project-test-devops-owners@qrispier.com"
    owners       = ["ernestognw@qrispier.com"]
  }
  project_id = "cicd-project-test"
}
storage_location = "us-central1"
state_bucket     = "cicd-project-test-state"
