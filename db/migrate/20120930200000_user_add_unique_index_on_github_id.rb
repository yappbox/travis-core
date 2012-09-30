class UserAddUniqueIndexOnGithubId < ActiveRecord::Migration
  def change
    remove_index 'users', ['github_id']
    add_index    'users', ['github_id'], :unique => true
  end
end
