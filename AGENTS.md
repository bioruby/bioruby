# BioRuby AGENTS.md file

## Setup commands
- Install deps: `sudo apt install ruby-full ruby-bundler`
- Install BioRuby: `sudo gem install bio`
- Run tests: `bundle exec rake`

## Code style
- Rubocop Default Ruby Style Guide

## Testing instructions
- Find the CI plan in the .github/workflows folder.
- From the package root you can just call `bundle exec rake`. The commit should pass all tests before you merge.
- Fix any test or type errors until the whole suite is green.
- After updating .rb files, run `rubocop` to be sure Rubocop rules still pass.
- Add or update tests for the code you change, even if nobody asked.
 
## PR instructions
- Always run `rubocop` and `bundle exec rake` before committing.
