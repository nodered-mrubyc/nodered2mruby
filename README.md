# nodered2mruby

- Node-REDのJSONファイルから、mrubyのコードを生成する
- nodered2mruby.rb は引数として JSONファイル を受け取り、mrubyコードを標準出力として出力する。

## 使い方

Node-REDのJSONファイルを sample.json とすると、以下のコマンドで mrubyコード sample.rb を作成できる。<br>

```
ruby nodered2mruby.rb ./sample.json > ./sample.rb
```

サンプルとなる JSON ファイルを sampleフォルダに入れている。

## [共通]ノードの処理

- inject
    - 一定時間ごとに、メッセージとしてpayloadプロパティの値を後続ノードに送信する。
- debug
    - 受け取ったメッセージを標準出力に出力する。
- switch
    - 条件判別を行い、条件に合致する後続ノードにデータを送信する。


## [mruby RBoard Nodes]ノードの処理
- LED
    - 受信データ（payload）の値によってLEDの点滅を行う。
- GPIO-Read
    - 指定したGPIOピンのデータを読み込み、後続ノードにデータを送信する。
- ADC
    - 指定したGPIOピンから読み込んだデータをアナログ信号からデジタル信号に変換し、後続ノードに送信する。
- GPIO-Write
    - 指定したGPIOピンにデータを書き込む。
- PWM
    - 指定したGPIOピンに周波数、デューティ比を設定し、PWM出力を制御する。
- I2C
    - データの書き込み・読み込みを選択し、I2C通信を通信の制御を行う。
- Button
    - 指定したGPIOピンに対してプルアップ/プルダウンの設定を行う。
- Constant
    - 設定したデータを後続ノードに送信する。
- function-ruby(未実装)
    - ユーザが記述したコードを関数として定義し、実行する。
