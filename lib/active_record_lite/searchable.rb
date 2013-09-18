require_relative './db_connection'

module Searchable
  def where(params)
    attributes = params.keys
    where_string = attributes.map {|attr| attr.to_s + " = ?"}.join(" AND ")
    values = attributes.map{|attr| params[attr]}

    query = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{where_string}
    SQL

    results = DBConnection.execute(query, values)
    self.parse_all(results)
  end
end