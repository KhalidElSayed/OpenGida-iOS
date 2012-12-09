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

#import "model/BICategory_item.h"

#import "categories/NSDictionary+Bidrasil.h"
#import "entity/BIEntity_view_controller.h"
#import "global/BIGlobal.h"
#import "index/BIIndex_view_controller.h"

#import "ELHASO.h"

@interface BICategory_item ()
@end

@implementation BICategory_item

@synthesize name = name_;
@synthesize type = type_;
@synthesize id_ = id_;
@synthesize indent = indent_;

/** Initializes a category element.
 * Category elements are required to have a name, type and identifier. If any
 * of those is not present, the initialisation will fail.
 */
- (id)init_with_json:(NSDictionary*)data
{
	if (!(self = [super init]))
		return nil;

#define _CHECK(COND, REASON) do { \
	if (!(COND)) { \
		DLOG(@"Error creating BICategory_item with %@.\n\nReason: %@", \
			data, REASON); \
		[self release]; \
		return nil; \
	} \
} while (0)

	self.name = [data get_string:@"name" def:nil];
	_CHECK(self.name.length > 0, @"Categories require a name");

	type_ = [data get_type:@"item_type" def:API_ERROR];
	_CHECK(API_ERROR != type_ , @"Unknown category item_type");

	id_ = [data get_int:@"id" def:-1];
	_CHECK(id_ >= 0, @"Missing category id or negative");
	indent_ = [data get_bool:@"indent" def:NO];

#undef _CHECK

	return self;
}

- (void)dealloc
{
	[name_ release];
	[super dealloc];
}

/** Creates a special generic error cell.
 * This cell can be used as a replacement for those cells which could not be
 * parsed properly for some reason and tell the user that something bad
 * happened in the process, but its our fault. Also, by using a known valid
 * BICategory_item we won't generate further paging requests to the server.
 */
+ (BICategory_item*)generic_error
{
	static BICategory_item *item = 0;
	if (!item) {
		item = [BICategory_item new];
		item.type = API_ERROR;
		item.name = _(CATEGORY_CELL_ERROR);
	}
	return item;
}

/** Similar to generic_error but you get to specify the message of the cell.
 * You will get the icon error and stuff. However, the returned cell won't be
 * following the singleton pattern.
 */
+ (BICategory_item*)specific_error:(NSString*)message
{
	BICategory_item *item = [BICategory_item new];
	item.type = API_ERROR;
	item.name = message;
	return [item autorelease];
}

/** Creates a dummy cell with a "touch to see more..." text.
 * Pass the total results for the search, which will be stored in the id_
 * property for later retrieval. Yeah, we looooove mangling variables' purpose
 * in life.
 *
 * \return Returns nil if the type is not people or entities. The returned text
 * will be i18n.
 */
+ (BICategory_item*)more_search:(API_TYPE)type total:(int)total
{
	RASSERT(total > 0, @"Bad total results for more cell",
		return [BICategory_item specific_error:@"Bad more_search total"]);
	RASSERT(API_ENTITY == type || API_PERSON == type, @"Bad more search type",
		return [BICategory_item specific_error:@"Bad more_search type"]);

	BICategory_item *item = [BICategory_item new];
	if (API_ENTITY == type) {
		item.type = API_SEARCH_MORE_ENTITIES;
		item.name = _(SEARCH_MORE_ENTITIES);
	} else {
		item.type = API_SEARCH_MORE_PEOPLE;
		item.name = _(SEARCH_MORE_PEOPLE);
	}
	item.id_ = total;

	return [item autorelease];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BICategory_item {id:%d, "
		"name:%@, type:%d, indent:%@}", id_, name_, type_,
		indent_ ? @"YES" : @"NO"];
}

/** Gets the appropriate view controller for the item being pointed at this.
 * \return The returned view controller needs only to be pushed on the
 * navigation stack. The method can return nil, in which case you shouldn't try
 * to push nil on the stack. Really.
 */
- (UIViewController*)get_controller
{
	switch (self.type) {
		case API_CATEGORY:
		{
			BIIndex_view_controller *c = [BIIndex_view_controller new];
			[c set_api:API_CATEGORY num:self.id_];
			c.item_title = self.name;
			return [c autorelease];
		}
		case API_ENTITY:
		{
			BIEntity_view_controller *c = [BIEntity_view_controller new];
			[c set_api:API_ENTITY num:self.id_];
			c.item_title = self.name;
			return [c autorelease];
		}
		default:
			return nil;
	}
}

/** Returns the type icon for the category item.
 * May return nil.
 */
- (UIImage*)get_icon
{
	return get_icon_for_api_type(self.type);
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
