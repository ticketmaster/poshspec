# ChangeLog

## [2.2.7] - 2019-06-13

### Added
* Added `SecurityOption` function for validating Local Security Policy Security Option settings -- Thanks [@markwragg](https://github.com/markwragg)

## [2.2.2] - 2018-06-22

### Fixed
* [BugFix] Loading of Pester module moved to the `RequiredModules` field of the Manifest as loading it via `Import-Module` was causing PowerShell Gallery to think the Pester cmdlets were part of this module, which caused issues installing PoshSpec unless `-NoClobber` was used. - Thanks [@AspenForester](https://github.com/AspenForester)

## [2.2.1] - 2017-05-13

### Changed
* Added PropertyExpression to `Get-PoshspecParams`
* Support added to Website and AppPool for accessing property values through dot notation.
See [#52](https://github.com/Ticketmaster/poshspec/pull/52) for details. Thanks [Jesse Gigler](https://github.com/jgigler).

## [2.1.19] - 2017-04-25

### Changed
* Expanded functionality for WebSite and AppPool [#49](https://github.com/Ticketmaster/poshspec/pull/49) [#50](https://github.com/Ticketmaster/poshspec/pull/50)

## [2.1.16] - 2017-02-15

### Changed
* Improved handling of single quotes in Package function

## [2.1.12] - 2016-07-26

### Added
* Added Functions for
  * LocalUser
  * AuditPolicy
  * Volume
  * ServerFeature
  * Share
  * UserRightsAssignment

### Changed
* Improved handling of single quotes  in Package function

## [2.1.10] - 2016-07-05

### Changed
* Added `-UseBasicParsing` switch to Http test function so that it works on a headless deployment (no Internet Explorer) - Thanks [@Sam-Martin](https://github.com/Sam-Martin)

## [2.1.6] - 2016-05-27

### Added
* Added Functions for
  * Firewall

## [2.1.0]

### Added
* Added Functions for
  * CheckSite
  * CheckAppPool
  * WebSite
  * SoftwareProduct

### Changed
* Broke Down PSM1 to Many Different Functions in their own files [No change in functionality]

## [1.2.2]

### Added
* Merged PR including 5 new functions
  * Package
  * LocalGroup
  * Interface
  * Folder
  * DnsHost

## [1.1.0]

* Public release.

## [1.0]

* Complete refactor to improve unit testing.
* Build unit tests.

## [0.3]

* Better Help
* A bug fix

## [0.2]

Reworked all functions.
 * Now using Cmdlet syntax to provider better Parameter handling.
 * Assertions are now defined in the test script for better flexibility.

## [0.1]

* Initial 6 functions
