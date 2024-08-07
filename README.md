Nginx-k8s-Helm
Этот проект представляет собой тестовое задание, включающее создание Docker-образа для запуска Nginx веб-сервера, его деплой в Kubernetes с использованием Helm, а также CI/CD скрипт для автоматизации сборки и деплоя.

***

[![Build](https://img.shields.io/badge/Build-stable-!)](https://hub.docker.com/layers/olejean/nginx-app/1.0.2/images/sha256-11063069e174d6b0a0a8d0a708f8965999ec82d0a4f25912919e0293b62d8f48?context=repo)
#####  В проекте используется ряд иструменнов с открытым исходным кодом :
- [GitHub](https://github.com/olejean/devops-diplom) - GitHub — крупнейший веб-сервис для хостинга IT-проектов и их совместной разработки.
- [CI/CD - GitLab](https://gitlab.com) - GitLab — это инструмент для хранения и управления репозиториями Git.
- [Kubernetes](https://kubernetes.io/) - Праграмное обеспечение для автоматизации развёртывания, масштабирования и управления контейнеризированными приложениями.
- [Helm](https://helm.sh//) - Helm — это менеджер пакетов для Kubernetes, который позволяет разработчикам и операторам быстрее собирать, настраивать и развёртывать приложения и сервисы в кластерах Kubernetes.
- [Docker](https://docker.com) -  программное обеспечение для автоматизации развёртывания и управления приложениями в средах с поддержкой контейнеризации, контейнеризатор приложений.
***

## Задание

Тестовое задание на позицию Devops инженера

Создать собственный докер-образ (разместить на docker hub):
–	запускающий web-сервер на 8000 порту
–	отдающий̆ содержимое директории /app внутри контейнера (например, если в директории /app лежит файл test.html, то при запуске контейнера данный̆ файл должен быть доступен по URL http://localhost:8000/test.html)
–	работающий̆ с UID 1001
 
Написать манифесты, необходимые  для деплоя данного образа в kubernetes. В манифест деплоя добавить проверки работоспособности и готовности приложения принимать трафик, а также ограничения по использованию ресурсов.
 
Написать свой helm чарт на основе созданных манифестов.
 
Написать ci-cd скрипт для сборки и деплоя данного образа в kubernetes.
 
Показать, каким образом можно проверить работоспособность запущенного приложения (можно описать несколько способов).

Показать, как можно обновить (рестартануть) одновременно все деплойменты, содержащие в наименовании слово «test». 

* Удалить все поды из namespace kube-system - объяснить почему все pod восстанавливаются после удаления. (core-dns и, например, kube-apiserver, имеют различия в механизме запуска и восстанавливаются по разным причинам)


## Описание и решение

Проект включает в себя:

- Docker-образ, запускающий Nginx веб-сервер на порту 8000 и отдающий содержимое директории `/app` внутри контейнера.
- Манифесты для деплоя данного образа в Kubernetes с проверками готовности и работоспособности.
- Helm чарт для удобного управления деплоями в Kubernetes.
- CI/CD скрипт для автоматизации сборки и деплоя Docker-образа в Kubernetes.

## Структура проекта

```
.
├── Dockerfile
├── README.md
├── app
│   └── test.html
├── deployment.yaml
├── helm
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── values.yaml
├── k8s
│   ├── deployment.yaml
│   └── service.yaml
├── nginx.conf
└── service.yaml
```

Сборка docker image
```sh
docker build -t olejean/nginx-app:latest .
```


Отправляем в репозиторий на DockerHub
```sh
docker push olejean/nginx-app:latest
```


Устанавливаем приложение через Helm
```sh
helm install nginx-app ./helm
```

Проверка работоспособности
```sh
curl -s localhost:8000
```
<!-- app/test.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <h1>Tesk task for Elfin, this is a test page! --check Helm</h1>
</body>
</html>
```

Удостоверимся что контейнер работает с UID 1001
```
kubectl exec pods/nginx-app-v2-nginx-app-db454bdf-4frn6 id
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
uid=1001(nginxuser) gid=1001(nginxuser) groups=1001(nginxuser)
```

 проверка работоспособности запущенного приложения
```
helm list
helm status nginx-app
kubectl get deployment/nginx-app-nginx-app -o wide
kubectl describe pod/nginx-app-nginx-app-5bcd7bcb4f-jtsln 
kubectl get pods
kubectl logs deployments/nginx-app-nginx-app
```

Предварительно (можно и после в любое время) добавив Label в Deployment   realease:test  мы можем перезапустить deployment  с этой меткой 
```sh
kubectl rollout restart deployment --selector=release=test
```



Удаление всех подов в namespace kube-system
```sh
kubectl delete pods --all -n kube-system
```
 
Почему поды восстанавливаются?
- CoreDNS: управляется Deployment. Когда поды удаляются, контроллер Deployment автоматически создает новые поды для поддержания заданного количества реплик.

- Kube-apiserver, kube-scheduler, kube-controller-manager: запускаются как статические поды. kubelet на каждом узле следит за манифестами в /etc/kubernetes/manifests и перезапускает поды, если они удалены.

Различия в механизмах запуска
CoreDNS: восстанавливается через Deployment контроллер.
Kube-apiserver, kube-scheduler, kube-controller-manager: восстанавливаются kubelet через статические поды.
Наблюдать за процессом восстановления:
```sh
kubectl get pods -n kube-system --watch
```

##CI/CD Gitlab
Создадим gitlab-running-secret.yaml зашифруем токен для регистрации runner | base64 добавим  в k8s
Конечно все шифрования лучше делать через плагин Helm Secrets, но на данный момент ограничемся этим, но знаю, умею, практикую.
```
kubectl apply  -f gitlab-runner-secret.yaml
```

Установим gitlab-runner
```
helm install  gitlab-runner -f ./helm/gitlab-runner/values.yaml gitlab/gitlab-runner
```


CI/CD пайплайн настроен для сборки Docker-образов с использованием Kaniko, инструмента, который не требует Docker Engine и прав root, что повышает безопасность, так как сборка выполняется в пользовательском режиме. Пайплайн запускается по коммитам с тегами, что соответствует лучшим практикам для непрерывной интеграции и доставки.
```
git commit - m "commit v1.0.3"
git tag 1.0.3
git push origin master --targ
```

