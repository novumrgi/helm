# NOVUM-RGI Helm Chart Library for Kubernetes

![NOVUM-RGI](images/novum_visual.jpg)

Helm charts for various applications, provided by [NOVUM-RGI](https://www.novum-rgi.com/).
All provided charts are ready to launch via Kubernetes Helm.

More Charts are going to be added.

# TL;DR

```
helm repo add novum-rgi https://novumrgi.github.io/helm/
helm install my-release novum-rgi/<chart>
```

# Information

[Gitea helm chart](https://gitea.com/gitea/helm-chart) has moved to [Gitea](https://www.gitea.com) https://gitea.com/gitea/helm-chart

## Charts

1. [AWX](charts/awx/README.md) in Version 15.0.0 -> Deprecated Please use the [AWX Operator](https://github.com/ansible/awx-operator)
2. [Glowroot](charts/glowroot/README.md) in Version 0.13.7
3. [Nexus2](charts/nexus2/README.md) oss latest
4. [Dependency Track](charts/dependency-track/README.md) latest