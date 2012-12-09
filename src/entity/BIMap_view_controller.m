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

#import "entity/BIMap_view_controller.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSObject+ELHASO.h"


@implementation BIAnnotation
@synthesize coordinate = coordinate_;
@synthesize title = title_;

- (void)dealloc
{
	[title_ release];
	[super dealloc];
}

@end


@implementation BIMap_view_controller

@synthesize place = place_;

- (void)loadView
{
	[super loadView];

	LASSERT(!map_view_, @"Double initialization");
	map_view_ = [[MKMapView alloc] initWithFrame:self.view.bounds];
	map_view_.showsUserLocation = YES;
	map_view_.autoresizingMask = FLEXIBLE_SIZE;
	map_view_.delegate = self;
	[self.view addSubview:map_view_];

	// Set the location if available.
	if (self.place) {
		MKCoordinateRegion region = { self.place.coordinate, { 0.1, 0.1} };
		[map_view_ setRegion:region animated:NO];
		[map_view_ addAnnotation:self.place];
		[self after:1 perform:^{
				[map_view_ selectAnnotation:self.place animated:YES];
			}];
	}

	UIBarButtonItem *button = [[UIBarButtonItem alloc]
		initWithTitle:_(MAPS_SHOW_BUTTON) style:UIBarButtonItemStylePlain
		target:self action:@selector(open_maps)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
}

- (void)dealloc
{
	map_view_.delegate = nil;
	[place_ release];
	[map_view_ release];
	[super dealloc];
}

/** User touched the open in maps button.
 * Create an URL and let the OS open it.
 */
- (void)open_maps
{
	if (!self.place)
		return;

	NSString *address = [NSString stringWithFormat:@"http://"
		@"maps.google.com/maps?ll=%f,%f", self.place.coordinate.latitude,
		self.place.coordinate.longitude];
	[self open_url:@"" address:address error_title:_(MAPS_ERROR_TITLE)
		error_text:_(MAPS_ERROR_MESSAGE)];
}

#pragma mark MKMapViewDelegate protocol

/** Generates the view pins for the map.
 * We need to implement this to provide pin animation.
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView
	viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (![annotation isKindOfClass:[BIAnnotation class]])
		return nil;

	NSString *identifier = @"BIMap_view_controller_item";

	MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView
		dequeueReusableAnnotationViewWithIdentifier:identifier];

	if (pin)
		pin.annotation = annotation;
	else
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
			reuseIdentifier:identifier] autorelease];

	pin.canShowCallout = YES;
	pin.animatesDrop = YES;
	pin.pinColor = MKPinAnnotationColorRed;
	return pin;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
