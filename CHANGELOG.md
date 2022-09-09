# Changelog

## [2.0.0] - 2020-04-28
### Changed
- Requires rspec >= 3 explicitly
- All tests and examples updated to RSpec 3 syntax
- Fixed bug with using subject in an example after group level "call" execution
### Removed
- "its" style functionality: calling(:method) { is_expected.to ... }
