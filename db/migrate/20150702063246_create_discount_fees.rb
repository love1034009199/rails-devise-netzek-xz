class CreateDiscountFees < ActiveRecord::Migration
  def change
    create_table :discount_fees do |t|
      t.string :discount_name
      t.text :discount_description
      t.text :discount_configure
      t.string :discount_remark

      t.timestamps null: false
    end
  end
end
