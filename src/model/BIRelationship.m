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

#import "model/BIRelationship.h"

#import "categories/NSDictionary+Bidrasil.h"
#import "model/BIRelationship_item.h"
#import "model/JSON_helpers.h"

#import "ELHASO.h"

#import <assert.h>

@interface BIRelationship ()
@end

@implementation BIRelationship

@synthesize type = type_;
@synthesize name = name_;
@synthesize items = items_;

/** Initializes a relationship object.
 */
- (id)init_with_data:(NSDictionary*)data
{
	LASSERT([data isKindOfClass:[NSDictionary class]], @"Bad data type");
	if (!(self = [super init]))
		return nil;

	self.name = [data get_string:@"section_name" def:nil];
	type_ = [data get_type:@"item_type" def:API_ERROR];

	if (self.name.length < 1) {
		DLOG(@"Can't create BIRelationship with emtpy name");
		[self release];
		return nil;
	}

	if (API_ERROR == self.type) {
		DLOG(@"Can't create BIRelationship with bogus item types");
		return nil;
	}

	self.items = parse_json_items(
		[data get_array:@"items" of:[NSDictionary class] def:nil],
		[BIRelationship_item class]);

	if (self.items.count < 1) {
		DLOG(@"Can't create BIRelationship without BIRelationship_item items");
		[self release];
		return nil;
	}

	return self;
}

- (void)dealloc
{
	[items_ release];
	[name_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIRelationship {type:%d, "
		@"name:%@, items:%@}", type_, name_, items_];
}

/** Returns the total count of rows of all children.
 * This is basically getting a count of each item in the array.
 */
- (int)total_rows
{
	int total = 0;
	for (BIRelationship_item *item in self.items)
		total += item.rows.count;
	return total;
}

/** Returns a row as if all children had been flattened into a list.
 * Similar to total_rows but instead returns the row according to the flattened
 * position, which is inside the range [0, total_rows]. Returns nil if out of
 * range.
 */
- (BIInteractive_row*)get_flat_row:(int)position
{
	for (BIRelationship_item *item in self.items)
		for (BIInteractive_row *row in item.rows)
			if (0 == position--)
				return row;

	return nil;
}

/** Returns the id of the BIRelationship_item matching the specified flat row.
 * Returns -1 if not found.
 */
- (int)flat_row_id:(int)position
{
	for (BIRelationship_item *item in self.items)
		for (BIInteractive_row *row in item.rows)
			if (0 == position--)
				return item.id_;

	return -1;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
