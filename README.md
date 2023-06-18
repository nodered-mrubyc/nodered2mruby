# nodered2mruby

- Node-REDのJSONファイルから、mrubyのコードを生成する
- nodered2mruby.rb は引数として JSONファイル を受け取り、mrubyコードを標準出力として出力する。

## 使い方

Node-REDのJSONファイルを sample.json とすると、以下のコマンドで mrubyコード sample.rb を作成できる。<br>

```
ruby nodered2mruby.rb sample.json > sample.rb
```

サンプルとなる JSON ファイルを sampleフォルダに入れている。

## [共通]ノードの処理

- inject
    - 一定時間ごとに、メッセージとしてpayloadプロパティの値を出力する
- debug
    - 受け取ったメッセージを標準出力に出力する

## [mruby RBoard Nodes]ノードの処理

