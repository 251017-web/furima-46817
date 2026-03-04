# PR Title

DB design for FURIMA required features

# What

- Added the database design section to `README.md`
- Added a local ER diagram document in `docs/er_diagram.md`
- Organized the schema around `users`, `items`, `orders`, and `addresses`

# Why

- The required features (user management, item listing, and item purchase) need a clear schema before implementation
- Separating shipping addresses from purchase records keeps the purchase record lean and easier to manage
- Defining associations and constraints up front reduces migration rework later

# ER Diagram

- Gyazo URL: `<< paste updated Gyazo URL here >>`

# Review Points

- Are the four core tables sufficient for the required features?
- Is the one-to-one relationship between `items` and `orders` appropriate?
- Are any columns or constraints missing for the first implementation pass?
