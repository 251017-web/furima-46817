class AddUniqueIndexToOrdersItemId < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :orders, :items
    remove_index :orders, :item_id if index_exists?(:orders, :item_id)
    add_index :orders, :item_id, unique: true
    add_foreign_key :orders, :items
  end
end
