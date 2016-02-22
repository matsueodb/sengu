class AddDomainIdToElements < ActiveRecord::Migration
  def change
    add_column :elements, :domain_id, :string
  end
end
