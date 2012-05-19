module Travis
  module Api
    module Json
      module Http
        class Organizations
          include Formats

          attr_reader :organizations

          def initialize(organizations, options = {})
            @organizations = organizations
          end

          def data
            organizations.map { |organization| organization_data(organization) }
          end

          def organization_data(organization)
            {
              'id' => organization.id,
              'name' => organization.name,
              'login' => organization.login,
            }
          end
        end
      end
    end
  end
end
