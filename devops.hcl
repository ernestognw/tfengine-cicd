# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# {{$recipes := "../../templates/tfengine/recipes"}}

data = {
  parent_type      = "folder" # One of `organization` or `folder`.
  parent_id        = "526868020083"
  billing_account  = "01C1BA-DBC5AE-2AF7A4"
  state_bucket     = "cicd-project-test-state"
  storage_location = "us-central1"
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    enable_gcs_backend = true

    admins_group = {
      id     = "cicd-project-test-org-admins@qrispier.com"
      customer_id = "C03yezfd5"
      owners = ["ernestognw@qrispier.com"]
    }

    project = {
      project_id = "cicd-project-test"
      owners_group = {
        id     = "cicd-project-test-devops-owners@qrispier.com"
        customer_id = "C03yezfd5"
        owners = ["ernestognw@qrispier.com"]
      }
    }
  }
}

# Must first be deployed manually before 'cicd' is deployed because some groups created
# here are used in 'cicd' template.
template "groups" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./groups"
  data = {
    project = {
      project_id = "cicd-project-test"
      exists     = true
    }
    resources = {
      groups = [
        {
          id          = "cicd-project-test-cicd-viewers@qrispier.com"
          customer_id = "C03yezfd5"
          owners = ["ernestognw@qrispier.com"]
        },
        {
          id          = "cicd-project-test-cicd-editors@qrispier.com"
          customer_id = "C03yezfd5"
          owners = ["ernestognw@qrispier.com"]
        },
      ]
    }
  }
}

template "cicd" {
  recipe_path = "{{$recipes}}/cicd.hcl"
  output_path = "./cicd"
  data = {
    project_id = "cicd-project-test"
    github = {
      owner = "ernestognw"
      name  = "tfengine-cicd"
    }

    # Required for scheduler.
    scheduler_region = "us-east1"

    build_viewers = ["group:cicd-project-test-cicd-viewers@qrispier.com"]
    build_editors = ["group:cicd-project-test-cicd-editors@qrispier.com"]

    terraform_root = ""
    envs = [
      {
        name        = "prod"
        branch_name = "main"
        # Prepare and enable default triggers.
        triggers = {
          validate = {}
          plan = {
            run_on_schedule = "0 12 * * *" # Run at 12 PM EST everyday
          }
          apply = {
            run_on_push = false # Do not auto run on push to branch
          }
        }
        managed_dirs = []
      }
    ]
  }
}
