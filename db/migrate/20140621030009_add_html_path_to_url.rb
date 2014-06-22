class AddHtmlPathToUrl < ActiveRecord::Migration
  def change
    add_column :urls, :html_path, :string
  end
end
