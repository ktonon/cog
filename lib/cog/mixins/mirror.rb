require 'cog/mixins/uses_templates'
module Cog
  module Mixins

    # Code the interface in Ruby and implement in the target langauge.
    #
    # <b>Not implemented</b>
    #
    # === Example
    # 
    # In Ruby
    #   class Dog
    #     include Cog::Mixins::Mirror
    #
    #     cog_reader :name, Cog::Type.string
    #     cog_accessor :age, Cog::Type.int
    #
    #     meth :speak
    #   end
    # 
    # In C++
    #   class CogDog
    #   {
    #   protected:
    #       char* _name;
    #       int _age;
    #   public:
    #       AbstractDog();
    #       virtual ~AbstractDog();
    #
    #       virtual const char* name() const { return _name; }
    #
    #       virtual int age() const { return _age; }
    #       virtual void setAge(int age) { _age = age; }
    #
    #       virtual void speak() = 0;
    #   };
    #
    #   class Dog : public CogDog
    #   {
    #   public:
    #       Dog();
    #       virtual ~Dog();
    #   
    #       virtual void speak();
    #   };
    #
    # The abstract class +CogDog+ will be regenerated whenever the source Ruby
    # specification is changed. The derived C++ class +Dog+ will only be
    # generated once. The C++ compiler will let you know if any abstract methods
    # are missing from +Dog+ when you try to instantiate it.
    module Mirror
      def self.included(base)
        base.include UsesTemplates
      end
      
      
    end
    
  end
end