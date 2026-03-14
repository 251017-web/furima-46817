# 購入ページの入力エラー赤字を見本アプリに揃えるための修正計画（実ページ確認ベース）

## 0. 実ページ確認結果（今回）

### 0-1. 見本アプリ（Heroku）確認
- 参照先: `https://furima2020.herokuapp.com/items/4264/orders`
- 実施内容:
  - Basic認証付きURLでアクセス
  - 指定されたログイン情報でサインインを試行
- 結果:
  - `users/sign_in` から先へ遷移できず、注文ページの実画面までは到達不可。
  - そのため見本は、今回添付いただいたスクリーンショットを正とみなして差分を確定する。

### 0-2. 実装中アプリ（localhost）確認
- 参照先: `http://localhost:3000/items/14/orders`
- 実施内容:
  - ローカル起動確認（`curl` / `bin/rails s`）
- 結果:
  - `localhost:3000` は未起動。
  - `bin/rails s` は `Ruby 3.2.3` と `Gemfile 3.2.0` の不一致で起動不可。

> 以上より、**コード実態 + 添付見本画像**を基準にピンポイントで修正プランを再構築する。

---

## 1. 差分の確定（コードベース）

1. 郵便番号のエラーメッセージ
- 現在: `is invalid. Include hyphen(-)`
- 見本: `is invalid. Enter it as follows (e.g. 123-4567)`

2. 電話番号エラーの粒度
- 現在: `format` 1本（`is invalid`）
- 見本: 以下のように分離
  - `Phone number is too short`
  - `Phone number is invalid. Input only number`

3. 番地の属性名
- 現在: `block` 由来で `Block can't be blank`
- 見本: `Addresses can't be blank`

4. 赤字スタイル
- 現在: `.error-message { font-size: 1.3vw; }`
- 見本画像では固定サイズ寄りの見た目で、viewport依存を減らした方が近い。

---

## 2. ピンポイント修正方針（ファイル単位）

### A. `app/models/order_address.rb`
- 郵便番号バリデーション文言を見本準拠へ変更。
- 電話番号バリデーションを分割:
  - `length`（最小10 / 最大11）
  - 数字のみチェック（`\A\d+\z` もしくは `numericality`）
- `allow_blank: true` を適切に使い、未入力時の `can't be blank` と重複表示を抑制。

### B. `config/locales/*.yml`（新規追加）
- `activemodel.attributes.order_address.block: Addresses`
- 必要に応じて `post_code`, `phone_number`, `token` も英語表示を明示し、見本の文言と一致させる。
- `errors.messages` の個別キーではなく、`order_address` モデル単位で上書きして影響範囲を限定する。

### C. `app/assets/stylesheets/shared/error_messages.css`
- `font-size` を固定値（例: `32px` ベースレイアウトなら相対縮尺を再計算した値）に調整。
- `line-height` / `margin-bottom` を調整し、見本の行間・詰まり具合に近づける。

### D. `app/views/shared/_error_messages.html.erb`
- 原則ロジック変更なし。
- ただし、順序が見本とズレる場合のみ `full_messages.uniq` の扱いを見直す（重複排除は維持優先）。

---

## 3. 実装ステップ（最短）

1. `order_address.rb` のバリデーションを修正。
2. locale追加で属性名/文言を合わせる。
3. `error_messages.css` を微調整。
4. 送信失敗ケースを手動確認（未入力、郵便番号不正、電話番号桁不足、電話番号記号混入）。

---

## 4. 完了条件（受け入れ基準）

- 未入力送信で、見本画像同等の赤字一覧が出る。
- 郵便番号 `1234567` 入力時に、見本文言が表示される。
- 電話番号 `09012` で `too short` が表示される。
- 電話番号 `090-1234-5678` で `invalid. Input only number` が表示される。
- 番地未入力で `Addresses can't be blank` が表示される。

---

## 5. 注意点

- DBカラム名は `block` のまま維持（マイグレーション不要）。
- 今回の対象は購入ページのエラー赤字に限定し、他フォームの汎用エラーパーツへの副作用を避ける。
