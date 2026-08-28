# Customer Insights Hackathon

このリポジトリでは、Oracle APEX アプリケーションの定義と、開発時に作成した設計・検証用ファイルを管理します。

## Git 管理対象

| パス | 内容 | 管理方針 |
| --- | --- | --- |
| `customer-insights-apex/` | Oracle APEX アプリケーション定義（`application.apx`、ページ、共有コンポーネント、静的ファイル） | 管理する |
| `customer-insights-apex/.apex/apexlang.json` | APEXlang のアプリケーション設定 | 管理する |
| `.apexlang/` | 要件・UX契約・SQL検証スクリプト | 管理する。ただし実行結果は除外する |
| `dataplatform/data/` | ハッカソン配布データ、展開済みデータ | 管理しない |

## 除外するもの

`.gitignore` で次を除外しています。

- `dataplatform/data/`: 元の入力ZIPだけで約292 MB、抽出済みデータを含めると約2.2 GBあります。顧客関連データを含む可能性もあるため、Gitには保存せず、承認済みの配布元から取得してください。
- `.apexlang/runtime-*`、`runtime-validation/`、実行ログ: APEXlangの実行ごとに生成される検証結果です。
- `.env*`、証明書・秘密鍵: 接続情報や認証情報の誤コミットを防ぎます。
- IDE・OSの個人設定ファイル: チームで共有する必要がないためです。

> 注意: APEX の接続先、パスワード、トークンなどの認証情報をアプリ定義や設定ファイルに直接記載しないでください。誤って追加した場合は、コミット前に削除し、漏えいした値は無効化してください。

## 初回のGit登録手順

リポジトリのルートはこの `hackason` ディレクトリです。GitHub などで空のリモートリポジトリを作成した後、以下を実行します。

```bash
cd hackason
git init
git branch -M main
git add .gitignore README.md customer-insights-apex .apexlang
git status
git commit -m "Initial commit: Customer Insights APEX application"
git remote add origin <リモートリポジトリURL>
git push -u origin main
```

`git status` で `dataplatform/data/` と `.apexlang/runtime-*` が表示されないことを確認してからコミットしてください。

## 日常の更新手順

```bash
cd hackason
git status
git add customer-insights-apex .apexlang README.md .gitignore
git diff --cached
git commit -m "Describe the change"
git push
```

入力データや接続設定を新たに追加する場合は、先に公開可否・個人情報・容量を確認してください。共有が必要な大容量データは、Gitではなくチームで合意したオブジェクトストレージなどで管理します。
