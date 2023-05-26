# Terraformサンプル

Localstack+DockerDesktop(k8s)を使用したargocd,dashbordのdemo環境

## 必要環境

* Bitbucket
    * SSH秘密鍵(repository access)
* k8s
    * DockerDesktop
    * kubectl
    * helm
* aws
    * localstack
    * awscli
* terraform
    * tfenv
    * tflint
* make

## Files

| path                           | desc                             |
|--------------------------------|----------------------------------|
| Makefile                       | コマンド操作ヘルパー             |
| global/backend.tf              | 共通のバックエンド設定           |
| global/providers_aws.tf        | 共通のプロバイダ設定(aws)        |
| global/providers_localstack.tf | 共通のプロバイダ設定(localstack) |
| global/locals.tf               | 共通の変数                       |
| global/versions.tf             | 共通のバージョン設定             |
| global/ip.sh                   | 自分PC(mac or linux)のIP取得     |
| stacks_k8s/                    | demo用のリソース                 |
| stacks_template/               | stacksのテンプレート             |

## Setup (k8s)

ingress経由でアクセスするためのFQDNを/etc/hostsに追加

```
127.0.0.1 argocd.example.local
127.0.0.1 nginx.example.local
127.0.0.1 dashboard.example.local
```

## Setup (aws)

aws-cliの設定。localstack用のプロファイル作成

```
$ aws configure
```

## Provisioning

ENVを省略するとdev(localstack)になります。

一括apply
```
$ make apply [ENV=dev] -C stacks_k8s
```

個別apply
```
$ make apply [ENV=dev] -C stacks_k8s/01_ssm
```

## Usage

* dashboard *

http://dashbord.example.local

「認証なし設定」なので認証画面のskipをクリックするとダッシュボードへ遷移する

* argocd *

http://argocd.example.local

[user]
admin
[initial password]
```
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

* sample app *

http://nginx.example.local

