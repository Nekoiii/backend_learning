module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :record, [RecordType], null: false,
      description: "Get record"
    def record
      Record.all
    end

    field :machine, [MachineType], null: false,
      description: "Get machine"
    def machine
      Machine.all
    end


    field :user, [UserType], null: false,
      description: "Get user"
    def user
      User.all
    end
    
    '''field :user do
      type UserType
      argument :id, !types.ID
      resolve ->(obj, args, ctx) {
        User.find(args[:id])
      }
    end'''

  end
end
