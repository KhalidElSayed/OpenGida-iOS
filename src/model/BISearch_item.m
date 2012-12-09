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

#import "model/BISearch_item.h"

#import "categories/NSDictionary+Bidrasil.h"
#import "entity/BIEntity_view_controller.h"
#import "global/BIGlobal.h"
#import "index/BIIndex_view_controller.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"

#import <CoreLocation/CLLocation.h>


@implementation BISearch_item

@synthesize lines = lines_;
@synthesize location = location_;

/** Dummy initializer, to avoid calling it by mistake.
 */
- (id)init_with_json:(NSDictionary*)data
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

/** Initializes a category element.
 * Search elements are required to have a line, type and identifier. If any
 * of those is not present, the initialisation will fail.
 *
 * NOTE: This ignores the parent constructor, it calls init.
 */
- (id)init_with_json:(NSDictionary*)data type:(API_TYPE)type
{
	if (!(self = [super init]))
		return nil;

#define _CHECK(COND, REASON) do { \
	if (!(COND)) { \
		DLOG(@"Error creating BISearch_item with %@.\n\nReason: %@", \
			data, REASON); \
		[self release]; \
		return nil; \
	} \
} while (0)

	self.lines = [data get_array:@"lines" of:[NSString class] def:nil];
	_CHECK(self.lines.count > 0, @"Searches require lines");

	type_ = type;
	_CHECK(API_ERROR != type_ , @"Unknown category item_type");

	id_ = [data get_int:@"id" def:-1];
	_CHECK(id_ >= 0, @"Missing search id or negative");

	NSArray *lat_lon = [data get_array:@"geolocation"
		of:[NSNumber class] def:nil];
	if (2 == lat_lon.count) {
		const double lat = [[lat_lon get:0] doubleValue];
		const double lon = [[lat_lon get:1] doubleValue];
		CLLocation *loc = [[CLLocation alloc]
			initWithLatitude:lat longitude:lon];
		self.location = loc;
		[loc release];
	}

#undef _CHECK

	return self;
}

- (void)dealloc
{
	[lines_ release];
	[location_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BISearch_item {id:%d, "
		"lines:%@, type:%d, location:%@}", id_, lines_, type_, location_];
}

/** Overrides the name getter to return the joined lines.
 */
- (NSString*)name
{
	return [self.lines componentsJoinedByString:@"\n"];
}

/** Gets the appropriate view controller for the item being pointed at this.
 * \return The returned view controller needs only to be pushed on the
 * navigation stack. The method can return nil, in which case you shouldn't try
 * to push nil on the stack. Really.
 */
- (UIViewController*)get_controller
{
	switch (self.type) {
		case API_PERSON:
		case API_ENTITY:
		{
			BIEntity_view_controller *c = [BIEntity_view_controller new];
			[c set_api:self.type num:self.id_];
			c.item_title = [self.lines get:0];
			return [c autorelease];
		}
		default:
			return [super get_controller];
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
