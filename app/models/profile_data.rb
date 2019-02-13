class ProfileData < ActiveRecord::Base
  # Relationships
  belongs_to :profile

  # Set accessible fields
  attr_accessible :profile_id, :published, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :col10, :row_content
end
