# How to deploy

## common

**create namespace**

```bash
$ kubectl create -f namespace.yaml
```

**deploy secrets**

```bash
$ kubectl apply -f secrets/
```

**deploy config maps**

```bash
$ kubectl apply -f configmaps/
```

## mysql

```bash
$ kubectl create -f mysql/persistent-volume.yaml
$ kubectl create -f mysql/persistent-volume-claim.yaml
$ kubectl apply -f mysql/deployment.yaml
$ kubectl apply -f mysql/service.yaml
```


## app

```bash
$ kubectl apply -f app/
```

## MetaLLB
**Install by Manifest**
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```
