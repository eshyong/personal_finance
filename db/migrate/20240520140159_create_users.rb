class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
