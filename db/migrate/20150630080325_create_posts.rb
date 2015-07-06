class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :user_name
      t.string :user_email
      t.text :user_remark

      t.timestamps null: false
    end
  end
end
