require 'active_support/inflector'
require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore
  end

  def self.all
    query = <<-SQL
        SELECT *
        FROM #{@table_name}
    SQL

    results = DBConnection.execute(query)

    self.parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
        SELECT *
        FROM #{@table_name}
        WHERE id = ?
      SQL
    self.new(results.first)
  end

  def save
    id.nil? ? create : update
  end

  private
  def create

    attribute_names = self.class.attributes.join(", ")
    question_marks_string = self.class.attributes.map do |attr|
                              "?"
                            end.join(", ")

    query = <<-SQL
      INSERT INTO #{self.class.table_name}
      (#{attribute_names})
      VALUES (#{question_marks_string})
    SQL

    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attribute_names = self.class.attributes.map {|attr| attr.to_s + " = ?"}
    attribute_names = attribute_names.join(", ")

    p attribute_names
    query = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{attribute_names}
      WHERE id = ?
    SQL

    DBConnection.execute(query, *attribute_values, @id)
  end


  def attribute_values
    self.class.attributes.map do |attr|
      self.send(attr)
    end
  end
end
