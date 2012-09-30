class RepositoryAddIndexOnNameAndOwnerName < ActiveRecord::Migration
  def change
    remove_index 'repositories', ['owner_name', 'name']
    add_index    'repositories', ['owner_name', 'name'], :unique => true
  end
end
