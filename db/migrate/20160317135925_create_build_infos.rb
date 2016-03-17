class CreateBuildInfos < ActiveRecord::Migration
  def change
    create_table :build_infos do |t|
      t.text :display
      t.string :colour
      t.datetime :time

      t.timestamps null: false
    end
  end
end
