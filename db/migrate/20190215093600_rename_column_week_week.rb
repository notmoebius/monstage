class RenameColumnWeekWeek < ActiveRecord::Migration[5.2]
  def change
    rename_column :weeks, :week, :number
  end
end