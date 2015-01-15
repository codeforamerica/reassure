class CreateAnswers < ActiveRecord::Migration
 def self.up
   create_table :answers do |t|
     t.float :facebook_id
     t.boolean :answer
     t.timestamps
   end
 end

 def self.down
   drop_table :answers
 end
end