# Lynput changelog
All Lynput changes will be documented in this file.

## [Unreleased]
### Changed
- The default gamepad deadzone <code>gpadDeadZone</code> value has been changed to 10 from 30.

### Added
- Analog values are now stored in actions. Check the <code>[MANUAL](MANUAL.md#gamepad)</code> for more details.
- When binding an action to an analog input, you can to not specify an interval, and it will be min:max. Check the <code>[MANUAL](MANUAL.md#gamepad)</code> for more details.

### Removed
- The method <code>getAxis(axis)</code> was removed since it breaks the abstraction Lynput bindings offer.

## [v1.1.0] - 2019-02-03
### Added
- Added method <code>getAxis(axis)</code> to get values from axes.
