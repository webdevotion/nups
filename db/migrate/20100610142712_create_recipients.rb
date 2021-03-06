class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.string :gender
      t.string :first_name
      t.string :last_name
      t.string :email
      
      t.integer :deliveries_count,  :null => false, :default => 0
      t.integer :bounces_count,  :null => false, :default => 0
      t.text :bounces
      
      t.belongs_to :account
      
      t.timestamps
    end
    
    add_index :recipients, [:id, :account_id], :unique => true
    add_index :recipients, :email
  end
end
