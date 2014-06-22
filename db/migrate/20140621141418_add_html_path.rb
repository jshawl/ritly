class AddHtmlPath < ActiveRecord::Migration
  def change
    drop_table :urls
    create_table :urls do |u|
      u.string :link
      u.text :hashed
      u.text :css
      u.text :html_path
      u.timestamps
    end
  end
end
