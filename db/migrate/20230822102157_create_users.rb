class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string "name"
      t.string "email"
      t.string "password_digest"
      t.string "remember_digest"
      t.boolean "admin", default: false
      t.index ["email"], name: "index_users_on_email", unique: true

      t.string "activation_digest"
      t.boolean "activated", default: false
      t.datetime "activated_at"
      t.timestamps
    end
  end
end
