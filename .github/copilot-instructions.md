# BioRuby Development Instructions for Copilot Agents

## Project Overview

BioRuby is a mature, comprehensive bioinformatics library for Ruby that provides tools for biological sequence analysis, database parsing, and external application integration. The project targets Ruby 2.7+ and includes ~197 source files with ~128 test files, totaling 3941 tests covering unit, functional, and network scenarios.

**Repository Structure:** Standard Ruby gem layout with lib/, test/, sample/, doc/ directories. Main entry point is `lib/bio.rb` which autoloads all modules under the Bio namespace.

**Dependencies:** Minimal external dependencies (matrix, rexml, rake, rdoc, test-unit) managed via Bundler.

## Build and Test Environment Setup

### Prerequisites and Installation
```bash
# Ruby 2.7+ is required (Ruby 3.2+ recommended)
# Install bundler if not available
gem install --user-install bundler
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"

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
# Expected: ~3941 tests, 0 failures (takes ~7-8 seconds)
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
- `appveyor.yml` - Windows CI configuration
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

### Common Issues and Solutions
- **Bundle permission errors:** Use `bundle config set path 'vendor/bundle'`
- **Missing bundler:** Install with `gem install --user-install bundler` and update PATH  
- **Network test failures:** Expected in isolated environments, focus on unit/functional tests
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

**Trust these instructions and only search for additional information if they prove incomplete or incorrect.**