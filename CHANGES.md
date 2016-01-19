2016-01-19, Version 1.3.2
=========================

 * Remove docs and docs-1.0 leave md files and img (crandmck)

 * Fix swift compatibility issue when init'ing repo (hideya kawahara)

 * Added resetPasswordWithEmail to trigger reset of the users password (Kevin Gödecke)

 * Enable unit test execution from 'npm test' (hideya kawahara)

 * Fix a regression introduced by PR #68 (hideya kawahara)

 * Refine `+[LBPersistedModelRepository repository]` (hideya kawahara)

 * Update Subclassing.md (Aleksandar Kex Trpeski)

 * test-server: fix Container's base class to Model (Miroslav Bajtoš)

 * Add modulemap to the framework (hideya kawahara)

 * Clean up headers for unit tests (hideya kawahara)

 * Make private headers project private (hideya kawahara)

 * Add missing MobileCoreServices and SystemConfiguration to Podspec (hideya kawahara)

 * Rearrange LBPersistedModel's success block typedefs (hideya kawahara)

 * Necessary changes to support PersistedModel.updateAll (hideya kawahara)

 * Pass only necessary parameter in [LBPersistedModel destroyWithSuccess] (hideya kawahara)

 * Add LBPersistedModelTests's testFindWithFilter, testFindOne and testFindOneWithFilter to defaultTestSuite (hideya kawahara)

 * Use NSInteger instead of long (hideya kawahara)

 * Clean-up [<model-repository> repository] implementations. (hideya kawahara)

 * Add support for Date type (hideya kawahara)

 * Add findWithFilter/findOneWithFilter (Raymond Feng)

 * Allow Obj-C property mapping to use primitive types for Number type (hideya kawahara)

 * Minor refinements for LBPersistedModelTests.m and LBPersistedModelSubclassingTests.m (hideya kawahara)

 * Add file deletion to LBFile and streaming/binary data upload/download methods to LBFileRepository (hideya kawahara)

 * Import of MobileCoreServices in LBFile.m improved as mentioned in #46 (Lennart Stolz)

 * Fix Issue #51 -- add explicit @synthesize for _id (hideya kawahara)

 * add support for compilation of push notification registration on iOS SDK on Xcode 4 and older (hideya kawahara)

 * Intorduce LB 2.0 Persisted Model support (hideya kawahara)

 * Compile on MacOSX (Sylvain Ageneau)

 * Convert unit tests to XCTest (Sylvain Ageneau)

 * Fix build error with AFNetworking 1.x on macOS (Sylvain Ageneau)

 * Fix the URL generation code so that it won't attach bogus parameters. (hideya kawahara)

 * Update to strong-remoting 2.x (Raymond Feng)

 * Remove the deprecation warning (Raymond Feng)

 * Fix implementation issues found in LBFile and SLRESTAdapter. Add a feature to the adapter's invoke methods for handling response data via output stream. (hideya kawahara)

 * Remove warnings: - validate poject settings as xcode 6 recommends (use ONLY_ACTIVE_ARCH for debug   and change test productType to "com.apple.product-type.bundle.ocunit-test") - remove SLRemotingTests/server files from the build targets - add MobileCoreServices.h and SystemConfiguration.h to LoopBack-Prefix.pch   (and remove Foundation.h) - add MobileCoreServices and SystemConfiguration frameworks to the test targets - remove libobjc.A.dylib from the build targets - add an explicit "@synthesize connected" to SLRESTAdapter.m Minor improvements: - rearrange files in xcode project navigator - register LoopBackTests/server with xcode for easier reference - fix a typo in LBUserTests.m (hideya kawahara)

 * Update push notification registration method for iOS 8 (hideya kawahara)

 * Add findCurrentUser and cachedCurrentUser to LBUserRepository (hideya kawahara)

 * Implement UserRepository.currentUserId (hideya kawahara)

 * Fix contract mistakes in LBUser -- Fix Issue 26 - Fix the verb for login method (changed from GET to POST) - Add missing contract configuration for login ("login?include=user") - Improve [LBUserTest -testLogout] to test if the logout actually took effect - Update test server's package.json to use loopback 2.x instead of 1.x   (this unveiled the above verb mistake issue) (hideya kawahara)

 * Change prefix from "AF" to "SLAF" for two more methods to avoid build error with AFNetowrking 1.x (hideya kawahara)

 * Preserve REST access token across application restarts (hideya kawahara)

 * Add unit test for SLRESTAdapter's custom request header handling (hideya kawahara)

 * Fix a subclassing issue in LBModel (hideya kawahara)

 * Update README.md (Rand McKinney)

 * Add 'StrongLoop Labs' (Rand McKinney)

 * Fix bad CLA URL in CONTRIBUTING.md (Ryan Graham)

 * fix(pods):Removes SenTestingKit Framework From Podspec (Alex Bell)

 * Add contribution guidelines (Ryan Graham)

 * Fix the tests (Raymond Feng)

 * Create the SLRemotingTests target (Raymond Feng)

 * Make LBAccessToken.h public (Raymond Feng)

 * Add SLRemoting (Raymond Feng)

 * Remove SLRemoting submodule (Raymond Feng)

 * Update module name (Raymond Feng)

 * Make AFNetworking and SLRemoting headers public (Raymond Feng)

 * Bump version (Raymond Feng)

 * Update refs to SLRemoting (Raymond Feng)

 * Update strong remoting version (Raymond Feng)

 * Update to dual MIT/StrongLoop license (Raymond Feng)

 * LBFile cleanup and switch to streaming upload (Stephen Hess)

 * Unit testing for Container, User and File (Stephen Hess)

 * LBContainer (Stephen Hess)

 * LBFile WIP (Stephen Hess)

 * Add User & AccessToken models and enable ACLs. (Miroslav Bajtoš)

 * Use loopback-push-notification from npmjs.org (Miroslav Bajtoš)

 * Cleanup (Stephen Hess)

 * User updated with proper access token handling. (Stephen Hess)

 * User class (Stephen Hess)


2014-01-06, Version 1.2.1
=========================

 * Bump version (Raymond Feng)

 * Enable docs (Raymond Feng)


2013-12-20, Version 1.1.0
=========================

 * First release!
