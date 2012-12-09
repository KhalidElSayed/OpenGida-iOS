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

#import "model/BIJSON_Category.h"

#import "global/BIGlobal.h"
#import "model/BICategory_item.h"
#import "model/BIPagination.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSDictionary+ELHASO.h"


@interface BIJSON_Category ()
- (void)parse_navigation_categories:(NSDictionary*)json;
- (void)parse_quick_index:(NSArray*)quick_index;
@end


@implementation BIJSON_Category

@synthesize pagination = pagination_;
@synthesize items = items_;
@synthesize navigation = navigation_;
@synthesize qi_titles = qi_titles_;
@synthesize qi_numbers = qi_numbers_;

/** Parses a JSON dictionary looking for pagination and sections.
 * \return Returns a nicely filled out BIJSON_Category class. The pagination
 * variables will be set to negative if there was no pagination or valid info.
 */
+ (BIJSON_Category*)parse_json:(NSDictionary*)json
{
	BIJSON_Category *ret = [BIJSON_Category new];
	if (!ret)
		return nil;

	ret.pagination = [BIPagination parse_json:[json get_array:@"pagination"
		of:[NSNumber class] def:nil]];
	[ret parse_navigation_categories:json];
	[ret parse_quick_index:[json get_array:@"quick_index" of:[NSArray class]
		def:nil]];

	// Find out how many category items were returend in this query.
	NSArray *potential_items = [json get_array:@"categories"
		of:[NSDictionary class] def:nil];

	ret.items = [NSMutableArray arrayWithCapacity:potential_items.count];

	// Parse them. If some fail, insert a null object instead.
	for (NSDictionary *data in potential_items) {
		BICategory_item *category = [[BICategory_item alloc]
			init_with_json:data];

		[ret.items addObject:category ? (id)category :
			[BICategory_item generic_error]];
		[category release];
	}

	if (ret.pagination.size > 0 &&
			potential_items.count > ret.pagination.size) {
		DEV_LOG(@"Query got us %d items, but the pagination says the size "
			@"is %d. Math is hard, ask Seonhwa!", potential_items.count,
			ret.pagination.size);
	}

	return [ret autorelease];
}

- (void)dealloc
{
	[qi_titles_ release];
	[qi_numbers_ release];
	[navigation_ release];
	[items_ release];
	[super dealloc];
}

/** Reads from the json variable the navigation items.
 * The method will replace the current navigation property with a new one
 * parsed from the json.
 */
- (void)parse_navigation_categories:(NSDictionary*)json
{
	self.navigation = nil;
	NSArray *nav_items = [json get_array:@"navigation" of:[NSDictionary class]
		def:nil];
	if (nav_items.count < 1)
		return;

	NSMutableArray *nav = [NSMutableArray arrayWithCapacity:nav_items.count];

	// Parse them. If some fail, insert a null object instead.
	for (NSDictionary *data in nav_items) {
		BICategory_item *category = [[BICategory_item alloc]
			init_with_json:data];
		if (category) {
			[nav addObject:category];
			[category release];
		} else {
			[nav addObject:[BICategory_item generic_error]];
		}
	}

	self.navigation = nav;
}

/** Returns the array that can be used for the full pagination.
 * This is the method you call when you don't have previous items and want to
 * create yourself a nice array which will be capable of holding all the
 * entries.
 *
 * \return Returns the array currently in use, or a bigger one if the
 * pagination specifies that there will be more items than those returned in
 * the first request.
 */
- (NSMutableArray*)prepare_for_first_use
{
	const int total = self.pagination.total;
	if (total > self.items.count) {
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:total];
		[items addObjectsFromArray:self.items];
		for (int f = items.count; f < total; f++)
			[items addObject:[NSNull null]];
		return items;
	} else {
		return self.items;
	}
}

/** Parses the given array as possible tuples with quick_index info.
 * If the parsing is ok, the qi_numbers and qi_titles will contain valid data,
 * otherwise they will contain nil.
 */
- (void)parse_quick_index:(NSArray*)quick_index
{
	self.qi_titles = nil;
	self.qi_numbers = nil;
	NSMutableArray *titles = [quick_index get_holder];
	NSMutableArray *numbers = [quick_index get_holder];
	int last_offset = 0;
	BOOL requires_sort = NO;

	for (id pair_object in quick_index) {
		if (![pair_object isKindOfClass:[NSArray class]]) {
			DLOG(@"Expecting index pair, found %@", pair_object);
			continue;
		}
		NSArray *pair = pair_object;
		if (2 != pair.count) {
			DLOG(@"Expecting two elements in pair, found %@", pair);
			continue;
		}
		NSString *title = [pair get:0];
		if (![title isKindOfClass:[NSString class]]) {
			DLOG(@"First element of tuple not string: %@", pair);
			continue;
		}
		NSNumber *number = [pair get:1];
		if (![number isKindOfClass:[NSNumber class]]) {
			DLOG(@"Second element of tuple not number: %@", pair);
			continue;
		}
		if (title.length < 1) {
			DLOG(@"String for index pair can't be empty: %@", pair);
			continue;
		}
		const int n = [number intValue];
		if (n < 0) {
			DLOG(@"Number for index pair can't be negative: %@", pair);
			continue;
		}
		if (n < last_offset) {
			DLOG(@"Unsorted offset %d < %d for %@, it's smaller "
				@"than the previous one", n, last_offset, title);
			requires_sort = YES;
		}
		last_offset = n;
		[titles addObject:title];
		[numbers addObject:number];
	}

	if (requires_sort) {
		DLOG(@"Sections were unsorted. Before: %@ - %@",
			[titles componentsJoinedByString:@", "],
			[numbers componentsJoinedByString:@", "]);
		// First create a temporary array with pairs.
		NSMutableArray *unsorted = [titles get_holder];
		int f = 0;
		for (NSString *title in titles)
			[unsorted addObject:[NSArray
				arrayWithObjects:[numbers objectAtIndex:f++], title, nil]];

		NSArray *sorted = [unsorted sortedArrayUsingComparator:^(id t1, id t2){
				const int n1 = [[t1 objectAtIndex:0] intValue];
				const int n2 = [[t2 objectAtIndex:0] intValue];
				if (n1 < n2)
					return NSOrderedAscending;
				else if (n1 > n2)
					return NSOrderedDescending;
				else
					return NSOrderedSame;
			}];

		// Empty the previous temporary arrays and refill them with the sort.
		[titles removeAllObjects];
		[numbers removeAllObjects];
		for (NSArray *tuple in sorted) {
			[titles addObject:[tuple objectAtIndex:1]];
			[numbers addObject:[tuple objectAtIndex:0]];
		}
		DLOG(@"Sections were unsorted. After:  %@ - %@",
			[titles componentsJoinedByString:@", "],
			[numbers componentsJoinedByString:@", "]);
	}

	LASSERT(titles.count == numbers.count, @"Invalid pairing");
	if (titles.count < 1)
		return;

	self.qi_titles = titles;
	self.qi_numbers = numbers;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
