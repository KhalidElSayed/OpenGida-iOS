//
// OpenGida v1.0 Cliente iOS
//
// Copyright 2011 eFaber, S.L.
// Copyrigth 2011 Secretaría General de Comunicación
//    Komunikaziorako Idazkaritza Nagusia
//    Gobierno Vasco – Eusko Jaurlaritza 
// Licencia con arreglo a la EUPL, Versión 1.1 o –en cuanto sean aprobadas 
// por la Comisión Europea– versiones posteriores de la EUPL (la Licencia);
// Solo podrá usarse esta obra si se respeta la Licencia. Puede obtenerse una 
// copia de la Licencia en: http://ec.europa.eu/idabc/eupl 
// Salvo cuando lo exija la legislación aplicable o se acuerde por escrito, 
// el programa distribuido con arreglo a la Licencia se distribuye TAL CUAL,
// SIN GARANTÍAS NI CONDICIONES DE NINGÚN TIPO, ni expresas ni implícitas.
// Véase la Licencia en el idioma concreto que rige los permisos y limitaciones 
// que establece la Licencia
//
//  http://opengida.efaber.net, opengida@efaber.net

#import "global/BIGPS.h"

#import "ELHASO.h"


#define _KEY_PATH			@"last_pos"


@implementation BIGPS

static BIGPS *g_;

@synthesize last_pos = last_pos_;
@synthesize gps_is_on = gps_is_on_;
@synthesize accuracy = accuracy_;
@synthesize delegate = delegate_;

/** Returns the pointer to the singleton BIGPS class.
 * The class will be constructed if necessary.
 */
+ (BIGPS*)get
{
	if (!g_) {
		g_ = [BIGPS new];
	}

	return g_;
}

/** Initialises the BIGPS class.
 */
- (id)init
{
	if (!(self = [super init]))
		return nil;

	manager_ = [[CLLocationManager alloc] init];
	if (!manager_) {
		LOG(@"Couldn't instantiate CLLocationManager!");
		return nil;
	}

	// Set no filter and try to get the best accuracy possible.
	accuracy_ = LOW_ACCURACY;
	manager_.distanceFilter = 150;
	manager_.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	manager_.delegate = self;

	return self;
}

- (void)dealloc
{
	[self stop];
	[manager_ release];
	[super dealloc];
}

/** Starts the GPS tracking.
 * Returns false if the location services are not available.
 */
- (bool)start
{
	if ([CLLocationManager locationServicesEnabled]) {
		if (!self.gps_is_on)
			DLOG(@"Starting to update location");

		[manager_ startUpdatingLocation];
		gps_is_on_ = YES;
		return true;
	} else {
		DLOG(@"Couldn't start location?");
		gps_is_on_ = NO;
		return false;
	}
}

/** Stops the GPS tracking.
 * You can call this function anytime, doesn't really fail.
 */
- (void)stop
{
	if (self.gps_is_on)
		DLOG(@"Stopping to update location");
	gps_is_on_ = NO;
	[manager_ stopUpdatingLocation];
}

/** Returns the string used by add_watcher: and removeObserver:.
 */
+ (NSString*)key_path
{
	return _KEY_PATH;
}

/** Registers an observer for changes to last_pos.
 * Observers will monitor the key_path value.
 */
- (void)add_watcher:(id)watcher
{
	[self addObserver:watcher forKeyPath:_KEY_PATH
		options:NSKeyValueObservingOptionNew context:nil];
}

/** Removes an observer for changes to last_pos.
 */
- (void)remove_watcher:(id)watcher
{
	[self removeObserver:watcher forKeyPath:_KEY_PATH];
}

/** Changes the desired accuracy of the GPS readings.
 * If the GPS is on, it will be reset just in case.
 */
- (void)set_accuracy:(ACCURACY)accuracy
{
	if (accuracy_ == accuracy)
		return;

	accuracy_ = accuracy;
	NSString *message = nil;
#define _MSG(X) \
	message = @"Setting accuracy to " # X ".";

	switch (accuracy) {
		case HIGH_ACCURACY:
			_MSG(HIGH_ACCURACY);
			manager_.distanceFilter = kCLDistanceFilterNone;
			manager_.desiredAccuracy = kCLLocationAccuracyBest;
			break;

		case MEDIUM_ACCURACY:
			_MSG(MEDIUM_ACCURACY);
			manager_.distanceFilter = 50;
			manager_.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			break;

		case LOW_ACCURACY:
			_MSG(LOW_ACCURACY);
			manager_.distanceFilter = 150;
			manager_.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			break;

		default:
			NSAssert(0, @"Unexpected accuracy value");
			return;
	}
#undef _MSG
	DLOG(@"%@", NON_NIL_STRING(message));

	if (self.gps_is_on) {
		[self stop];
		[self start];
	}
}

#pragma mark CLLocationManagerDelegate

/** Something bad happened retrieving the location. What?
 * We simply stop the gps tracking with any error.
 */
- (void)locationManager:(CLLocationManager *)manager
	didFailWithError:(NSError *)error
{
	if (kCLErrorDenied == [error code])
		DLOG(@"Denied location services");
	else
		DLOG(@"locationManager error: %@", error);

	[self stop];
	[delegate_ gps_denied];
}

/** Receives a location update.
 * This generates the correct KVO messages to notify observers.
 * Also resets the watchdog. Repeated locations based on timestamp
 * will be discarded.
 */
- (void)locationManager:(CLLocationManager*)manager
		didUpdateToLocation:(CLLocation*)new_location
		fromLocation:(CLLocation*)old_location
{
	if (new_location.horizontalAccuracy < 0) {
		DLOG(@"Bad returned accuracy, ignoring update.");
		return;
	}

	if (self.last_pos &&
			[self.last_pos.timestamp isEqualToDate:new_location.timestamp]) {
		DLOG(@"Discarding repeated location %@", [new_location description]);
		return;
	}

	DLOG(@"Updating to %@", [new_location description]);

	// Keep the new location for map showing.
	[self willChangeValueForKey:_KEY_PATH];
	[new_location retain];
	[last_pos_ release];
	last_pos_ = new_location;
	[self didChangeValueForKey:_KEY_PATH];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
