# BioRuby Copilot Instructions

## Repository Overview

**BioRuby** is a Ruby library for bioinformatics (biology + information science). It provides tools for parsing biological databases, sequence analysis, structure prediction, phylogenetics, and more. The project is mature, stable, and widely used in the bioinformatics community.

**Key Facts:**
- **Size**: ~9.4MB total, 197 Ruby files in lib/, 58,438 lines of code
- **Language**: Ruby (requires Ruby 2.7+ recommended, supports 2.7, 3.0-3.3, head, jruby)
- **Type**: Ruby gem/library distributed via RubyGems
- **License**: Same terms as Ruby
- **Namespace**: All classes and modules are under the `Bio` module

## Build and Test Instructions

### Prerequisites and Setup
**ALWAYS** run these commands before making any changes:

```bash
# Install bundler if not available
sudo gem install bundler

# Install dependencies (required before any build/test)
bundle install
```

### Core Commands - Run These in Order

1. **Install Dependencies**: `bundle install`
   - **ALWAYS** run this first in a fresh environment
   - Time: ~30-60 seconds depending on network

2. **Run Tests**: `bundle exec rake test`
   - Runs unit and functional tests (~3941 tests)
   - Time: ~7-8 seconds
   - **MUST PASS** before committing any changes
   - Alternative: `bundle exec rake test-all` (includes network tests)

3. **Lint Code**: `bundle exec rubocop`
   - Checks code style and quality
   - Time: ~5-10 seconds
   - **MUST PASS** before committing any changes
   - May show minor warnings but should not show blocking errors

### Available Rake Tasks
```bash
bundle exec rake --tasks    # List all available tasks
bundle exec rake test       # Run unit/functional tests (DEFAULT)
bundle exec rake test-all   # Run all tests including network tests
bundle exec rake test-network  # Run only network tests
bundle exec rake rdoc       # Generate documentation
bundle exec rake gem        # Build gem package
```

### Validation Pipeline (REQUIRED)
**Run this sequence before every commit:**
```bash
bundle install              # Install/update dependencies
bundle exec rake test      # Run test suite (must pass)
bundle exec rubocop        # Lint code (must pass)
```

## Project Architecture and Layout

### Directory Structure
```
bioruby/
├── .github/workflows/     # CI/CD workflows (GitHub Actions)
├── lib/bio/              # Main library code
│   ├── bio.rb           # Main entry point with autoloads
│   ├── appl/            # External application wrappers/parsers
│   ├── data/            # Basic biological data
│   ├── db/              # Database entry parsers  
│   ├── io/              # I/O interfaces (files, RDB, web services)
│   ├── sequence/        # Sequence classes (DNA, RNA, protein)
│   ├── tree/            # Phylogenetic trees
│   └── util/            # Utilities and algorithms
├── test/                # Test suite
│   ├── unit/            # Unit tests
│   ├── functional/      # Functional tests
│   ├── network/         # Network-dependent tests
│   └── data/            # Test data files
├── sample/              # Example/demo scripts
├── etc/                 # Configuration files
├── doc/                 # Documentation
├── Rakefile             # Build configuration
├── Gemfile              # Dependencies
├── .rubocop.yml         # Linting configuration
└── README.rdoc          # Main documentation
```

### Key Files for Development
- **lib/bio.rb**: Main entry point with autoload declarations
- **lib/bio/version.rb**: Version information
- **Rakefile**: Build system configuration
- **Gemfile**: Runtime and development dependencies
- **.rubocop.yml**: Code style configuration (inherits from .rubocop_todo.yml)
- **bioruby.gemspec**: Gem specification (auto-generated from .erb)

### Code Organization Pattern
BioRuby uses a modular architecture with autoloaded modules:
- All classes/modules are under the `Bio` namespace
- Each major functionality area has its own subdirectory
- Use `autoload` for lazy loading of modules
- Follow existing naming conventions (see Coding Style below)

## Continuous Integration

### GitHub Actions Workflows
1. **Ruby CI** (`.github/workflows/ruby.yml`):
   - Tests against Ruby 2.7, 3.0, 3.1, 3.2, 3.3, head, jruby, jruby-head
   - Runs `bundle exec rake test`
   - Must pass for PR merge

2. **RuboCop CI** (`.github/workflows/rubocop.yml`):
   - Runs `bundle exec rubocop` 
   - Must pass for PR merge

### Pre-commit Checklist
**ALWAYS verify before committing:**
- [ ] `bundle install` - dependencies up to date
- [ ] `bundle exec rake test` - all tests pass
- [ ] `bundle exec rubocop` - no linting errors
- [ ] Added/updated tests for any new functionality
- [ ] Documentation updated if needed

## Coding Style and Standards

### Ruby Style Guide (RuboCop Configuration)
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Flexible (configured in .rubocop.yml)
- **Naming Conventions**:
  - CamelCase for module/class names
  - snake_case for method names and variables
  - ALL_UPPERCASE for constants
- **Method Definitions**: Use parentheses: `def method(arg1, arg2)`
- **Comments**: Use RDoc format for documentation, avoid `=begin/=end` blocks

### File Structure Patterns
When adding new functionality, follow existing patterns:
- **Applications**: `lib/bio/appl/toolname/`
- **Databases**: `lib/bio/db/database.rb`
- **Sequence Types**: `lib/bio/sequence/type.rb`
- **Utilities**: `lib/bio/util/algorithm.rb`

### Testing Patterns
- Tests mirror the lib/ structure under test/unit/
- Use Test::Unit framework (not RSpec)
- Test files named `test_*.rb`
- Include test data in test/data/ if needed

## Common Issues and Workarounds

### Environment Issues
- **Permission Errors**: May need `sudo` for global gem installation
- **Bundler Issues**: Use `bundle install` not `gem install` for dependencies
- **Ruby Version**: Ensure Ruby 2.7+ for compatibility

### Testing Issues
- **Network Tests**: Some tests require internet connection
- **Timing**: Tests typically run quickly (~7-8 seconds)
- **Test Isolation**: Each test file can be run independently

### RuboCop Issues
- **Legacy Code**: Some files may have minor style warnings
- **Configuration**: Custom rules in .rubocop.yml, inherits from .rubocop_todo.yml
- **Non-blocking**: Minor warnings acceptable, blocking errors must be fixed

## Quick Reference

### Essential Commands
```bash
# Setup
bundle install

# Development cycle
bundle exec rake test      # Test changes
bundle exec rubocop        # Check style
git add -A && git commit   # Commit if both pass

# Additional testing
bundle exec rake test-all  # Include network tests
ruby test/runner.rb        # Alternative test runner
```

### File Locations
- Main lib: `lib/bio.rb`
- Version: `lib/bio/version.rb` 
- Tests: `test/unit/bio/`
- Config: `.rubocop.yml`, `Gemfile`, `Rakefile`
- CI: `.github/workflows/`

### Documentation
- `README.rdoc`: User documentation and installation
- `README_DEV.rdoc`: Developer guidelines and coding standards
- `KNOWN_ISSUES.rdoc`: Known platform/version issues
- `doc/`: Additional documentation and release notes

**Trust these instructions** - they have been validated against the current codebase. Only search for additional information if these instructions are incomplete or found to be incorrect.