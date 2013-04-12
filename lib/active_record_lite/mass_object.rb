class MassObject
  @attributes = []

  def self.set_attrs(*attributes)
    @attributes = attributes

    attributes.each do |attribute|
      # add setter/getter methods
      attr_accessor attribute
    end
  end

  def self.attributes
    @attributes
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end