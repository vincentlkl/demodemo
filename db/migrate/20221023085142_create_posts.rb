class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :url, null: false
      t.string :cover_image_url, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :provider, null: false, default: 0
      t.references :category, index: true, foreign_key: true
      t.string :author
      t.datetime :published_at
      t.timestamps
    end
    add_index :posts, :url, unique: true
  end
end
