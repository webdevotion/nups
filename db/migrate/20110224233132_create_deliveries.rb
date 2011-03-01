class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries do |t|
      t.belongs_to :newsletter

      t.string    :type

      t.string    :state
      t.integer   :recipients_count
      t.timestamp :start_at

      t.integer   :last_id,   :null => false, :default => 0
      t.integer   :oks,       :null => false, :default => 0
      t.integer   :fails,     :null => false, :default => 0
      t.integer   :bounces,   :null => false, :default => 0

      t.timestamp :finished_at

      t.timestamps
    end
  end

  def self.down
    drop_table :deliveries
  end
end
