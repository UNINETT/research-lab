#!/bin/bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

tf_dir="terraform-uh-iaas"
if [ ! -f ${tf_dir}/local.tfvars ]; then
    echo "You must create terraform/local.tfvars" >&2
    exit 1
fi

pushd ${tf_dir}

terraform apply -var-file uh-iaas.tfvars -var-file local.tfvars 
terraform output inventory >../ansible/inventory
popd

./ansible/apply.sh
