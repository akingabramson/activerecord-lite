require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelcase
    @primary_key = params[:primary_key] || "id"
    @foreign_key = params[:foreign_key] || name.to_s + "_id"
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelcase
    @primary_key = params[:primary_key] || "id"
    @foreign_key = params[:foreign_key] || "#{self_class.underscore}_id"
    # other class has foreign key, which is your class name
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = aps

    define_method(name) do

      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.primary_key} = ?
      SQL

      results = DBConnection.execute(query, self.send(aps.foreign_key))
      aps.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)

    define_method(name) do

      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.foreign_key} = ?
      SQL

      results = DBConnection.execute(query, self.send(aps.primary_key))

      aps.other_class.parse_all(results)

    end
  end

  def has_one_through(name, assoc1, assoc2)
    middle_table_params = assoc_params[assoc1]
    # class Human hasn't been defined yet in this case

    define_method(name) do
      end_table_params = middle_table_params.other_class.assoc_params[assoc2]
      # now it has been defined

      query = <<-SQL
        SELECT #{end_table_params.other_table}.*
        FROM #{end_table_params.other_table}
        JOIN #{middle_table_params.other_table}
        ON #{middle_table_params.other_table}.#{end_table_params.foreign_key} = #{end_table_params.other_table}.#{end_table_params.primary_key}
        WHERE #{middle_table_params.other_table}.#{middle_table_params.primary_key} = ?
      SQL

      results = DBConnection.execute(query, self.send(middle_table_params.foreign_key))
      end_table_params.other_class.parse_all(results)
    end

  end
end
