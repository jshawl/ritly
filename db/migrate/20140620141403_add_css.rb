class AddCss < ActiveRecord::Migration
  def self.up
    add_column :urls, :css, :text
  end
end
