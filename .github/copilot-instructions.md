# BioRuby Development Instructions for Copilot Agents

## Repository Overview

BioRuby is a mature, comprehensive bioinformatics library for Ruby that provides tools for biological sequence analysis, database parsing, and external application integration. The project targets Ruby 2.7+ and includes ~197 source files with ~128 test files, totaling 3941 tests covering unit, functional, and network scenarios.

**Repository Structure:** Standard Ruby gem layout with lib/, test/, sample/, doc/ directories. Main entry point is `lib/bio.rb` which autoloads all modules under the Bio namespace.

**Dependencies:** Minimal external dependencies (matrix, rexml, rake, rdoc, test-unit) managed via Bundler.

## Build and Test Environment Setup

### Prerequisites and Installation
```bash
# Ruby 2.7+ is required (Ruby 3.2+ recommended)
# Install bundler if not available
gem install --user-install bundler
export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"

# Always install gems in vendor directory to avoid permission issues
bundle config set path 'vendor/bundle'
bundle install
```

### Running Tests and Validation

**Standard Test Suite (ALWAYS run this):**
```bash
bundle exec rake test
# OR
bundle exec ruby test/runner.rb
# Expected: all tests should pass with 0 failures (typically completes in ~7-8 seconds)
```

**All Tests (including network - will fail without internet):**
```bash
bundle exec rake test-all
# NOTE: Network tests will fail in isolated environments
```

**Default Task (runs tests):**
```bash
bundle exec rake
```

**Test Categories:**
- `test/unit/` - Core unit tests (always pass offline)
- `test/functional/` - Integration tests (always pass offline) 
- `test/network/` - Network-dependent tests (fail without internet)

### Critical Build Notes
- **ALWAYS use bundler commands:** `bundle exec rake` instead of plain `rake`
- **PATH setup required:** Include gem bin directory when using user-installed bundler
- **Vendor bundle:** Use `bundle config set path 'vendor/bundle'` to avoid permission issues
- **Test timing:** Unit tests complete in ~8 seconds, use 300s timeout for safety
- **Network failures expected:** Network tests fail in sandboxed environments - this is normal

### Available Rake Tasks
```bash
bundle exec rake --tasks    # List all available tasks
bundle exec rake test       # Run unit/functional tests (DEFAULT)
bundle exec rake test-all   # Run all tests including network tests
bundle exec rake test-network  # Run only network tests
bundle exec rake rdoc       # Generate documentation
bundle exec rake gem        # Build gem package
```

## Project Architecture and Layout

### Core Directory Structure
```
lib/bio.rb              # Main entry point, autoloads all modules
lib/bio/                # Core Bio namespace modules
├── sequence/           # Sequence analysis (DNA, RNA, protein)
├── db/                 # Database format parsers (GenBank, EMBL, etc.)
├── appl/               # External application wrappers (BLAST, FASTA, etc.)
├── io/                 # I/O interfaces (file, web services, databases)
├── util/               # Utilities and algorithms
└── data/               # Biological data constants

test/runner.rb          # Test execution entry point
test/bioruby_test_helper.rb  # Test configuration and helpers
sample/                 # Demo scripts and usage examples
doc/                    # Tutorials, release notes, changelogs
Rakefile               # Build automation and gem packaging
bioruby.gemspec        # Gem specification (auto-generated from .erb)
KNOWN_ISSUES.rdoc      # Important: known platform/version issues
README_DEV.rdoc        # Development guidelines and coding standards
```

### Key Configuration Files
- `Gemfile` - Minimal dependencies (matrix, rexml, rake, rdoc, test-unit)
- `.github/workflows/ruby.yml` - CI for Ruby 2.7-3.3, JRuby
- `.github/workflows/rubocop.yml` - RuboCop CI workflow
- `appveyor.yml` - Windows CI configuration
- `.rubocop.yml` - Code style configuration (inherits from .rubocop_todo.yml)
- `etc/bioinformatics/seqdatabase.ini` - Database access configuration

### Architecture Patterns
- **Autoloading:** Heavy use of autoload for performance (lib/bio.rb shows pattern)
- **Namespace:** All classes under Bio module (Bio::Sequence, Bio::Blast, etc.)
- **Parser pattern:** Database format parsers in bio/db/ follow consistent API
- **Application wrappers:** External tool integration in bio/appl/

### Version and Release Management
- Version defined in `lib/bio/version.rb` as array `[2, 0, 6]`
- Gemspec auto-generated from `bioruby.gemspec.erb` via rake
- ChangeLog updated via `rake rechangelog` using git log

### Development Workflow Validation
1. **Before changes:** Run `bundle exec rake test` to ensure clean baseline
2. **After changes:** Always re-run `bundle exec rake test` 
3. **Code style:** Follow existing patterns (CamelCase classes, underscore_methods)
4. **Documentation:** RDoc format required for new code
5. **Testing:** Add unit tests in test/unit/ for new functionality

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
- [ ] `bundle exec rubocop` - no linting errors (if available)
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

## Common Issues and Solutions

### Environment Issues
- **Bundle permission errors:** Use `bundle config set path 'vendor/bundle'`
- **Missing bundler:** Install with `gem install --user-install bundler` and update PATH  
- **Network test failures:** Expected in isolated environments, focus on unit/functional tests
- **Ruby Version**: Ensure Ruby 2.7+ for compatibility

### Testing Issues
- **Network Tests**: Some tests require internet connection - failures expected in sandboxed environments
- **Timing**: Tests typically run quickly (~7-8 seconds), use 300s timeout for safety
- **Test Isolation**: Each test file can be run independently

### Code Development
- **Autoload dependencies:** Check lib/bio.rb for module loading patterns
- **Library loading:** Use `ruby -I lib` or `$LOAD_PATH.unshift('./lib')` for development version
- **HACK/TODO markers:** Found throughout codebase, existing issues not your responsibility to fix
- **Warning messages:** Bio::UniProt/Bio::SPTR deprecation warnings are expected and safe to ignore

### Sample Usage (for validation)
```ruby
# When working with local development version
ruby -I lib -e "require 'bio'; seq = Bio::Sequence.auto('ATGCATGC'); puts seq.translate"
# Or in script files:
$LOAD_PATH.unshift('./lib')
require 'bio'
seq = Bio::Sequence.auto('ATGCATGC')
puts seq.translate  # Output: MH (protein translation)
```

## Quick Reference

### Essential Commands
```bash
# Setup
bundle config set path 'vendor/bundle'
bundle install

# Development cycle
bundle exec rake test      # Test changes
git add -A && git commit   # Commit if tests pass

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

**Trust these instructions and only search for additional information if they prove incomplete or incorrect.**