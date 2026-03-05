# FURIMA DB Design

## Overview

FURIMA's required features are supported by these four core tables:

- `users`: account and profile data
- `items`: listings created by sellers
- `orders`: purchase records that connect buyers to items
- `addresses`: shipping destinations entered at purchase time

Shipping addresses are separated from purchase records because the address fields are numerous and are only needed when an item is purchased. Credit card details are not stored.

## ER Diagram

- Draw.io source: [docs/er_diagram.drawio](docs/er_diagram.drawio)
- Mermaid source: [docs/er_diagram.md](docs/er_diagram.md)

## users

| Column | Type | Options |
| ------ | ---- | ------- |
| nickname | string | null: false |
| email | string | null: false, unique: true |
| encrypted_password | string | null: false |
| last_name | string | null: false |
| first_name | string | null: false |
| last_name_kana | string | null: false |
| first_name_kana | string | null: false |
| birth_date | date | null: false |

### Association

- has_many :items
- has_many :orders

## items

| Column | Type | Options |
| ------ | ---- | ------- |
| name | string | null: false |
| description | text | null: false |
| category_id | integer | null: false |
| status_id | integer | null: false |
| shipping_fee_status_id | integer | null: false |
| prefecture_id | integer | null: false |
| scheduled_delivery_id | integer | null: false |
| price | integer | null: false |
| user | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- has_one :order

## orders

| Column | Type | Options |
| ------ | ---- | ------- |
| user | references | null: false, foreign_key: true |
| item | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :item
- has_one :address

## addresses

| Column | Type | Options |
| ------ | ---- | ------- |
| postal_code | string | null: false |
| prefecture_id | integer | null: false |
| city | string | null: false |
| house_number | string | null: false |
| building_name | string |  |
| phone_number | string | null: false |
| order | references | null: false, foreign_key: true |

### Association

- belongs_to :order

## Notes

- Add a unique index to `users.email` to prevent duplicate accounts.
- Add a unique index to `orders.item_id` so that one item can only be purchased once.
- `category_id`, `status_id`, `shipping_fee_status_id`, `prefecture_id`, and `scheduled_delivery_id` are intended for ActiveHash-style master data.
- `building_name` is optional because some addresses do not include one.
