class CreatePrimaryFees < ActiveRecord::Migration
  def change
    create_table :primary_fees do |t|
      t.string :primary_name
      t.text :primary_description
      t.text :primary_configure
      t.string :primary_remark

      t.timestamps null: false
    end
  end
end
