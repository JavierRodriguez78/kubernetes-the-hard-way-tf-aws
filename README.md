# About

This guide was created following the awesome [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) by Kelsey Hightower. It's a lot of copy pasting, so all credit to him.

I consulted [Prabhat Sharma](https://github.com/prabhatsharma) adaption of [Kubernetes The Hard Way (AWS)](https://github.com/prabhatsharma/kubernetes-the-hard-way-aws)

This guide also makes use of Terraform to automatically deploy the infrastructure and Ansible to provision it.

There are some shell and asible scripts provided to fully automate the whole process.

# Kubernetes The Hard Way

This tutorial walks you through setting up Kubernetes the hard way. This guide is not for people looking for a fully automated command to bring up a Kubernetes cluster. If that's you then check out [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine), [AWS Elastic Container Service for Kubernetes](https://aws.amazon.com/eks/) or the [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/).

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Target Audience

The target audience for this tutorial is someone planning to support a production Kubernetes cluster and wants to understand how everything fits together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.17.2
* [containerd Container Runtime](https://github.com/containerd/containerd) 1.3.2
* [gVisor](https://github.com/google/gvisor) 08879266fef3a67fac1a77f1ea133c3ac75759dd
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.8.2
* [etcd](https://github.com/coreos/etcd) 3.4.0

## Labs

This tutorial assumes you have access to the [Amazon Web Service](https://aws.amazon.com/). If you are looking for GCP version of this guide then look at : [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

* [Prerequisites](docs/01-prerequisites.md)
* [Installing the Client Tools](docs/02-client-tools.md)
* [Provisioning Compute Resources](docs/03-compute-resources.md)
* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](docs/10-configuring-kubectl.md)
* [Provisioning Pod Network Routes](docs/11-pod-network-routes.md)
* [Deploying the DNS Cluster Add-on](docs/12-dns-addon.md)
* [Smoke Test](docs/13-smoke-test.md)
* [Cleaning Up](docs/14-cleanup.md)

