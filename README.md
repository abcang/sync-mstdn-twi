sync-mstdn-twi
===

特定のTwitterアプリから投稿されたツイートをMastodonにも投稿するアプリ

## 環境
* Bundler
* Ruby

## 設定
各環境変数に値を設定します。

* `TWITTER_CONSUMER_KEY`: TwitterのConsumer Key
* `TWITTER_CONSUMER_SECRET`: TwitterのConsumer Secret
* `TWITTER_OAUTH_TOKEN`: TwitterのAccess Token
* `TWITTER_OAUTH_TOKEN_SECRET`: TwitterのAccess Token Secret
* `TWITTER_USER_IDS`: 自身のTwitterアカウントのID(not screen_name)
* `MASTODON_URL`: 投稿先のMastodonインスタンスのURL
* `MASTODON_ACCESS_TOKEN`: Mastodonのアクセストークン
* `APPLICATION_#{n}`: 対象のTwitterアプリケーション名(nは1〜10)

## 起動

```bash
$ bundle install --path vendor/bundle --deployment
$ cat > .env
TWITTER_CONSUMER_KEY=XXXXXXXX
TWITTER_CONSUMER_SECRET=XXXXXXXX
TWITTER_OAUTH_TOKEN=XXXXXXXX
TWITTER_OAUTH_TOKEN_SECRET=XXXXXXXX
TWITTER_USER_IDS=123456789
MASTODON_URL=https://pawoo.net
MASTODON_ACCESS_TOKEN=XXXXXXXX
APPLICATION_1=Hatena
APPLICATION_2=Annict
^D
$ ruby main.rb .env
```

## Dockerを使って起動

```bash
docker run \
    -e "TWITTER_CONSUMER_KEY=XXXXXXXX" \
    -e "TWITTER_CONSUMER_SECRET=XXXXXXXX" \
    -e "TWITTER_OAUTH_TOKEN=XXXXXXXX" \
    -e "TWITTER_OAUTH_TOKEN_SECRET=XXXXXXXX" \
    -e "TWITTER_USER_IDS=123456789" \
    -e "MASTODON_URL=https://pawoo.net" \
    -e "MASTODON_ACCESS_TOKEN=XXXXXXXX" \
    -e "APPLICATION_1=Hatena" \
    -e "APPLICATION_2=Annict" \
    abcang/sync-mstdn-twi
```

## 更新履歴
* 2017/11/02: 公開

## ライセンス
MIT
