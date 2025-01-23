# frozen_string_literal: true

module RolemodelSower
  class Category < RolemodelSower::Base
    def load!
      ::Category.find_or_create_by!(
        name: data[:name]
      )
    end
  end
end
