**This gem provides validation methods for Ruby class.**

Instance methods:
```
validate!
valid?
```

Class methods:
```
validate
```

Usage example:
```
  class Employee
    include JustValidate

    attr_reader :name, :nick, :supervisor

    def initialize(name:, nick:, supervisor:)
      @name = name
      @nick = nick
      @supervisor = supervisor
    end

    validate :name, presence: true
    validate :nick, format: /\A[a-z]{0,5}\z/
    validate :supervisor, type: Manager
  end
```

It is possible to create instance and call methods:

```
employee = Employee.new(name: name, nick: nick, supervisor: supervisor)
employee.validate!
employee.valid?
```
