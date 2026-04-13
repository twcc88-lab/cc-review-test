# Code Review Guidelines

## Focus
- Reentrancy and checks-effects-interactions violations
- Missing or incorrect access control on state-changing functions
- Arithmetic issues (overflow, underflow, precision loss)
- Untrusted external calls and hook callbacks
- Fund-loss paths

## Skip
- Gas optimization
- Formatting / style nits
- Natspec completeness
