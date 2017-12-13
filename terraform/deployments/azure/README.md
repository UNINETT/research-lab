# Azure Terraform #

- https://github.com/terraform-providers/terraform-provider-azurerm
- http://www.anniehedgie.com/terraform-and-azure

Hvis man får problemer med at terraform ikke vil kjøre, så kan man slette noen tilstandsfiler:
`$ rm terraform.tfstate terraform.tfstate.backup`

## Azure Scale Set ##

- https://azure.microsoft.com/nb-no/blog/new-networking-features-in-azure-scale-sets/
- https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking

## Loadbalancer ##

- http://blog.superautomation.co.uk/2016/11/azure-resource-manager-load-balancer.html

## Know-how ##

### SSH ###

Connect: ssh -p 50000 username@ip
http://rabexc.org/posts/using-ssh-agent

    eval `ssh-agent`
    ssh-add ~/.ssh/id_rsa

### Ubuntu ###

https://stackoverflow.com/questions/35144550/how-to-install-cryptography-on-ubuntu
'sudo apt-get install build-essential libssl-dev libffi-dev python-dev'

### Kubernetes ###

- http://kubernetesbyexample.com/
- https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/

På lokal maskin kjørte vi videre:

    $ cd ../../../ansible
    $ cat kubeconfig
    $ kubectl --kubeconfig=kubeconfig-cluster-<clustername> get node
    $ kubectl --kubeconfig=kubeconfig-cluster-<clustername> get pod -n kube-system

Slik kjører man et shell på en kontainer i clusteret (usikker på hva "shell" er, men det kan være en tilfeldig streng. label)
`$ kubectl --kubeconfig=kubeconfig-cluster-<clustername> run --rm -ti --image=alpine shell sh`

Jobbing med nginx
`export KUBECONFIG=et-eller-annet`

### Docker ###

`docker ps`
`docker logs <container id>`
`curl https://localhost:8443 -k`

## Kubernetes on Windows ##

https://docs.microsoft.com/en-us/virtualization/windowscontainers/kubernetes/getting-started-kubernetes-windows


    Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
    Install-Package -Name Docker -ProviderName DockerMsftProvider
    Restart-Computer -Force

    wget https://github.com/Microsoft/SDN/archive/master.zip -o master.zip
    Expand-Archive master.zip -DestinationPath master
    mkdir C:/k/
    mv master/SDN-master/Kubernetes/windows/* C:/k/
    rm -recurse -force master,master.zip

    docker pull microsoft/windowsservercore:1709
    #docker tag $(docker images -q) microsoft/windowsservercore:latest
    docker tag microsoft/windowsservercore:1709 microsoft/windowsservercore:latest
    cd C:/k/
    docker build -t kubeletwin/pause .

    wget https://dl.k8s.io/v1.9.0-beta.2/kubernetes-node-windows-amd64.tar.gz -o kubernetes-node-windows-amd64.tar.gz
    Install-Package 7Zip4Powershell
    Expand-7zip

### Copy master certificate to windows worker ###

    core@akube01-master-0 /etc/kubernetes $ cat kubeconfig-cm.yaml

Put this into c:\k\config file

Add to workers hosts file `C:\Windows\System32\drivers\etc\hosts`

    <linux worker ip>	apiserver.cluster.local


### Generate worker certificate ###

/mnt/c/runemy/git/research-lab/ansible$ ./tls/generate_cert.sh kubelet server akube01-wsworker-0
runemy@runemy:/mnt/c/runemy/git/research-lab/ansible/tls/kubelet$ ls