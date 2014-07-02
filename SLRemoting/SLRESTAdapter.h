/**
 * @file SLRESTAdapter.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRemotingUtils.h"
#import "SLAdapter.h"
#import "SLRESTContract.h"

/**
 * A specific SLAdapter implementation for RESTful servers.
 *
 * In addition to implementing the SLAdapter interface, SLRESTAdapter contains a
 * single SLRESTContract to map remote methods to custom HTTP routes. _This is
 * only required if the HTTP settings have been customized on the server._ When
 * in doubt, try without.
 *
 * @see SLRESTContract
 */
@interface SLRESTAdapter : SLAdapter

/** A custom contract for fine-grained route configuration. */
@property (readwrite, nonatomic, strong) SLRESTContract *contract;

/** Set the given access token in the header for all RESTful interaction. */
@property (nonatomic) NSString* accessToken;

@end
