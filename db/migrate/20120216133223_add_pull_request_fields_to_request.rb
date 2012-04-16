class AddPullRequestFieldsToRequest < ActiveRecord::Migration
  def ddl_transaction(&block)
    block.call # do not start a transaction
  end

  def change
    add_column :requests, :event_type, :string
    add_column :requests, :comments_url, :string
    add_column :requests, :base_commit, :string
    add_column :requests, :head_commit, :string
  end
end
