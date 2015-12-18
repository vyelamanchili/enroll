module Queries
  module QueryHelpers
    def last(value, from_expression=nil)
      lookup_expression = from_expression.nil? ? "$#{value}" : from_expression
      ::Queries::PipelineExpression.new({value => {"$last" => lookup_expression}})
    end

    def group_by(id_stuff, other_props = {})
      ::Queries::GroupExpression.new(
        id_stuff,
        other_props
      )
    end

    def project(exps ={})
      ::Queries::ProjectExpression.new(exps)
    end

    def project_property(name, exp)
      ::Queries::ProjectExpression.new({
        name => exp
      })
    end
  end
end
