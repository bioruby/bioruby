# RBS Type Signatures for BioRuby

This directory contains Ruby type signatures (RBS) for the BioRuby library. RBS provides static type information that can be used with type checkers and IDE tools to improve code safety and developer experience.

## What is RBS?

RBS is Ruby's official type signature language. It allows you to:
- Define types for Ruby methods, classes, and modules
- Enable static type checking with tools like Steep
- Improve IDE support with better autocompletion and error detection
- Document your API with precise type information

## Files

- `bio.rbs` - Main Bio module and Bio::Sequence class signatures
- `sequence.rbs` - Bio::Sequence::NA, Bio::Sequence::AA and related sequence class signatures
- `feature.rbs` - Bio::Feature and Bio::Feature::Qualifier class signatures
- `location.rbs` - Bio::Location and Bio::Locations class signatures
- `reference.rbs` - Bio::Reference class signatures

## Usage

### Validation

To validate all RBS signatures:

```bash
bundle exec rake rbs:validate
# or
bundle exec rbs -I sig validate
```

Note: `-I sig` is required so that the signatures in this directory are loaded
(`rbs validate` alone only validates the bundled core/standard library).
The `rbs` gem requires Ruby >= 3.1 and MRI, so it is only added to the
development bundle on supported interpreters.

### Type Checking

Static type checking is not currently enabled in CI; only `rbs validate` runs.
To type check your own code against these signatures, you can use tools like
[Steep](https://github.com/soutaro/steep):

1. Add steep to your Gemfile:
   ```ruby
   gem 'steep', require: false
   ```

2. Create a `Steepfile`:
   ```ruby
   target :lib do
     signature "sig"
     check "lib"
   end
   ```

3. Run type checking:
   ```bash
   bundle exec steep check
   ```

### IDE Integration

Many Ruby-aware editors can use RBS signatures to provide better:
- Code completion
- Method signature hints
- Type error detection
- Navigation and refactoring tools

## Development

When adding new classes or modifying existing ones, please update the corresponding RBS signatures to maintain type safety.

### Adding New Signatures

1. Create or edit the appropriate `.rbs` file in this directory
2. Follow RBS syntax guidelines: https://github.com/ruby/rbs
3. Optionally bootstrap signatures from source (MRI only):
   `bundle exec rbs prototype rb lib/bio/your_class.rb`
4. Validate signatures: `bundle exec rake rbs:validate`
5. Test that your changes don't break existing functionality

### RBS Syntax Examples

```rbs
# Class definition
class MyClass
  # Attribute with getter and setter
  attr_accessor name: String

  # Method with parameters and return type
  def process: (String input, ?Integer limit) -> Array[String]

  # Method with block
  def each: () { (String) -> void } -> void
end

# Module
module MyModule
  # Constant
  VERSION: String

  # Class method
  def self.create: (Hash[Symbol, untyped] options) -> MyClass
end
```

## Resources

- [RBS Documentation](https://github.com/ruby/rbs)
- [RBS Syntax Guide](https://github.com/ruby/rbs/blob/master/docs/syntax.md)
- [Steep Type Checker](https://github.com/soutaro/steep)