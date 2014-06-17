class AddUrls < ActiveRecord::Migration
  def change
    create_table :urls do |u|
      u.string :link
      u.text :hashed
      u.timestamps
    end
  end
end
