class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.integer :recipe_id
      t.integer :user_id
      t.integer :stars

      t.timestamps
    end
  end
end
