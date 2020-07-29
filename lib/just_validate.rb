module JustValidate
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    ['reader', 'writer', 'accessor'].each do |method|
      define_method("attr_#{method}") do |*attrs|
        @attributes ||= []
        @attributes += attrs
        super(*attrs)
      end
    end

    def attributes
      @attributes
    end

    # This method takes two arguments: attribute name and options with validation types and rules.
    # These are possible validation:
    # presence - requires an attribute to be neither nil nor an empty string.
    # Usage example:
    # validate :name, presence: true
    #
    # format - requires an attribute to match the passed regular expression.
    # Usage example:
    # validate :number, format: /A-Z{0,3}/
    #
    # type - requires an attribute to be an instance of the passed class.
    # Usage example:
    # validate :owner, type: User
    def validate(attr_k, condition)
      raise "Wrong attribute '#{attr_k}'" unless attributes.include? attr_k
      validator_k = condition.keys.first
      validator_c = condition.values.first
      begin
        validator_class = Object.const_get "JustValidate::#{validator_k.to_s.capitalize}Validator"
      rescue
        raise NotImplementedError, "#{validator_k} is not implemented"
      end

      @validators ||= []
      @validators << validator_class.new(attr_k, validator_c)
    end

    def validators
      @validators
    end
  end

  class BaseValidator
    attr_reader :attr_k, :condition, :attr_v

    def initialize(attr_k, condition)
      @attr_k = attr_k
      @condition = condition
    end

    def validate!(obj)
      @attr_v = obj.public_send(attr_k)
    end

    def valid?(obj)
      @attr_v = obj.public_send(attr_k)
    end
  end

  class PresenceValidator < BaseValidator
    def validate!(obj)
      super
      raise ":#{attr_k} for #{obj} should be present" if attr_v.nil? || attr_v.empty?
    end

    def valid?(obj)
      super
      if attr_v.nil? || attr_v.empty?
        ":#{attr_k} is empty or nil"
      end
    end
  end

  class FormatValidator < BaseValidator
    def validate!(obj)
      super
      raise ":#{attr_k} for #{obj} should match the format: #{condition.inspect}" unless attr_v.match?(condition)
    end

    def valid?(obj)
      super
      unless attr_v.match?(condition)
        ":#{attr_k} does not match to #{condition}"
      end
    end
  end

  class TypeValidator < BaseValidator
    def validate!(obj)
      super
      raise ":#{attr_k} for #{obj} should be kind of #{condition}" unless attr_v.is_a?(condition)
    end

    def valid?(obj)
      super
      unless attr_v.is_a?(condition)
        ":#{attr_k} is not a kind of #{condition}"
      end
    end
  end

  # validate! runs all checks and validations, that added to a class via the class method validate.
  # In case of any mismatch it raises an exception with a message that says what exact validation failed.
  def validate!
    self.class.validators.each do |validator|
      validator.validate!(self)
    end
    nil
  end

  # valid? returns true if all validations pass and false if there is any validation fail.
  def valid?
    @errors ||= []
    self.class.validators.each do |validator|
      @errors << validator.valid?(self)
    end
    @errors.uniq!
    @errors.compact!
    @errors.none?
  end

  def errors
    @errors ||= []
  end
end
