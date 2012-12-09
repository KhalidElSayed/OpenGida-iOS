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

#import "model/BIJSON_Search.h"

#import "categories/NSDictionary+Bidrasil.h"
#import "global/BIGlobal.h"
#import "model/BIPagination.h"
#import "model/BISearch_item.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSDictionary+ELHASO.h"


@implementation BIJSON_Search

- (void)dealloc
{
	[super dealloc];
}

/** Dummy implementation to avoid calling this by mistake.
 */
+ (id)parse_json:(NSDictionary*)json
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

/** Parses a JSON dictionary looking for search results.
 * Pass the search term. It is used for error messages when creating
 * [BICategory_item specific_error] objects.
 *
 * \return Returns a nicely filled out BIJSON_Search class.
 */
+ (id)parse_json:(NSDictionary*)json search_term:(NSString*)search_term
{
	NSArray *results = [json get_array:@"results"
		of:[NSDictionary class] def:nil];
	NSMutableArray *valid_items = [results get_holder];
	NSMutableArray *valid_sections = [results get_holder];

	// Construct the final object.
	BIJSON_Search *ret = [[BIJSON_Search new] autorelease];
	if (!ret)
		return nil;

	for (NSDictionary *group in results) {
		NSString *title = [group get_string:@"name" def:nil];
		if (title.length < 1) {
			DLOG(@"Ignoring unnamed result group %@", group);
			continue;
		}
		const API_TYPE type = [group get_type:@"item_type" def:API_UNKNOWN];
		if (API_UNKNOWN == type) {
			DLOG(@"Ignoring unkown API type in group %@", group);
			continue;
		}

		NSArray *potential_items = [group get_array:@"items"
			of:[NSDictionary class] def:nil];
		NSMutableArray *items = [potential_items get_holder];
		// Parse them. If some fail, insert a null object instead.
		for (NSDictionary *data in potential_items) {
			BISearch_item *search = [[BISearch_item alloc]
				init_with_json:data type:type];

			[items addObject:search ? (id)search :
				[BISearch_item generic_error]];
			[search release];
		}

		if (items.count) {
			const int total_results = [group
				get_int:@"total_results" def:items.count];

			// Should we add a dummy cell for more?
			if (total_results > items.count)
				[items addObject:[BICategory_item more_search:type
					total:total_results]];

			[valid_items addObject:items];
			[valid_sections addObject:title];
		}
	}

	if (valid_items.count < 1)
		[valid_items addObject:[BICategory_item
			specific_error:_F(SEARCH_NO_RESULTS, NON_NIL_STRING(search_term))]];

	ret.items = valid_items;
	ret.navigation = valid_sections;
	return ret;
}

/** Parses a JSON dictionary looking for paginated search results.
 * You have to pass the type of the expected entries that have to be created,
 * since the JSON doesn't contain their type.
 *
 * \return Returns a nicely filled out BIJSON_Search class.
 */
+ (id)parse_json:(NSDictionary*)json type:(API_TYPE)type
{
	// Adapt the type for the cells.
	if (API_SEARCH_PEOPLE == type)
		type = API_PERSON;
	else if (API_SEARCH_ENTITIES == type)
		type = API_ENTITY;

	// Hack, we are doing the sub-part of one type of items.
	NSDictionary *data = [[json get_array:@"results"
		of:[NSDictionary class] def:nil] get:0];
	if (!data) {
		DEV_LOG(@"Expected 'results' in json, but got %@", json);
		return nil;
	}
	NSArray *potential_items = [data get_array:@"items"
		of:[NSDictionary class] def:nil];
	BIPagination *pagination = [BIPagination parse_json:[data
		get_array:@"pagination" of:[NSNumber class] def:nil]];

	if (!pagination || !potential_items) {
		DEV_LOG(@"No pagination or items in %@!", data);
		return nil;
	}

	// Construct the final object.
	BIJSON_Search *ret = [[BIJSON_Search new] autorelease];
	if (!ret)
		return nil;

	ret.pagination = pagination;

	NSMutableArray *items = [potential_items get_holder];
	// Parse them. If some fail, insert a null object instead.
	for (NSDictionary *potential_item in potential_items) {
		BISearch_item *search = [[BISearch_item alloc]
			init_with_json:potential_item type:type];

		[items addObject:search ? (id)search :
			[BISearch_item generic_error]];
		[search release];
	}

	ret.items = items;
	return ret;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
