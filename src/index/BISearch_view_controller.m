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

#import "index/BISearch_view_controller.h"

#import "global/BIGlobal.h"
#import "global/BITitle_header.h"
#import "index/BISearch_cell.h"
#import "model/BICategory_item.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "UILabel+ELHASO.h"
#import "UIImageView+ELHASO.h"

#import <QuartzCore/CALayer.h>


#define _FADE_IN_SPEED					0.3
#define _FADE_OUT_SPEED					1
#define _LOCK_SECONDS					1
#define _DEFAULT_SECTION_HEIGHT			22


@implementation BISearch_view_controller

@synthesize location = location_;

- (void)loadView
{
	[super loadView];
}

- (void)dealloc
{
	[location_ release];
	[search_text_ release];
	[super dealloc];
}

/// Empty method to avoid creating a search bar for the view.
- (void)loadView_search
{
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BISearch_view_controller "
		@"{api:%@, location:%@}", api_, location_];
}

/** Overrides parent method to abort.
 */
- (void)set_api:(API_TYPE)type num:(int)num
{
	[api_ cancel];
	[api_ release];
	[self doesNotRecognizeSelector:_cmd];
}

/** Allows searching for text.
 * Use this instead of set_api:num: for this class type.
 */
- (void)set_search:(NSString*)text
{
	// Keep the search term for ourselves.
	[text retain];
	[search_text_ release];
	search_text_ = text;

	[api_ cancel];
	[api_ release];
	api_ = [[BIAPI_entry alloc] init_with_search:text
		location:self.location delegate:self];
}

/*** Prepares a controller to perform a paginated search.
 * Pass the type of the entity to do the pagination for, the limit of returned
 * elements in the search and the initial search api object to retrieve from it
 * the initial search parameters like query text and location.
 */
- (void)paginate_search:(API_TYPE)type total_count:(int)total_count
	initial_search:(BIAPI_entry*)initial_search
{
	[api_ cancel];
	[api_ release];
	api_ = [[BIAPI_entry alloc] init_with_search:type total_count:total_count
		initial_search:initial_search delegate:self];
}

/** Searches don't allow global refresh API.
 */
- (void)force_api_refresh
{
	DLOG(@"Calling unexpected BISearch_view_controller::force_api_refresh");
#ifdef DEBUG
	[self doesNotRecognizeSelector:_cmd];
#endif
}

/** Called when the user changes globally the content language.
 * The parent class would only refresh the api and wait for the viewWillAppear
 * to requery the connection. The search results, however, don't work like
 * this, since the language can't change directly under feet (the user is
 * unable to reach the preferences from a search results view). So we also
 * force the connection directly here.
 */
- (void)refresh_api:(NSNotification*)notification
{
	run_on_ui(^{
			DLOG(@"refreshing api %@", notification);
			[self set_search:search_text_];
			if ([api_ start])
				[self show_connecting_label];
			self.items = nil;
			self.navigation = nil;
			[self.tableView reloadData];
			[self set_ui_labels];
		});
}

#pragma mark -
#pragma mark BISerialization_protocol

/** Searches are not persistant.
 */
- (NSArray*)get_serialization_tuple
{
	return nil;
}

#pragma mark -
#pragma mark BIItem_receiver protocol

/** Receives notifications of new items to show.
 * The specified items will be associated with the view controller. This
 * updates the whole list. Note that the navigation array, unlike the parent
 * class, should contain the same number of items.count elements, and they
 * should be strings.
 */
- (void)update_items:(NSArray*)items navigation:(NSArray*)navigation
	qi_titles:(NSArray*)qi_titles qi_numbers:(NSArray*)qi_numbers
{
	[self hide_connecting_label];
	self.items = items;

	BOOL allow_retries = NO;
	for (BICategory_item *item in items)
		if ([item respondsToSelector:@selector(type)] && API_ERROR == item.type)
			allow_retries = YES;
	if (allow_retries)
		[self show_retry_button:@selector(refresh_api:)];

	self.navigation = navigation;
	self.qi_titles = qi_titles;
	self.qi_numbers = qi_numbers;
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

/** Tells us that the BIAPI_entry has updated a range of the items.
 */
- (void)update_range:(NSArray*)indices
{
	LASSERT(!first_page_, @"Pagination on index, you crazy?");
	[self.tableView reloadRowsAtIndexPaths:indices
		withRowAnimation:UITableViewRowAnimationFade];
}

/** Returns the NSIndexPath section for the update_range: method.
 */
- (int)get_item_section
{
	return 0;
}

#pragma mark -
#pragma mark UITableView delegates

/** Returns the search item for the specified index path.
 * May return nils.
 */
- (BICategory_item*)get_category:(NSIndexPath*)path
{
	if (self.navigation.count < 1)
		return [self.items get_non_null:path.row];

	NSArray *items = self.navigation.count < 1 ? self.items :
		[self.items get:path.section];
	RASSERT([items isKindOfClass:[NSArray class]], @"Bad array type?",
		return nil);
	return [items get_non_null:path.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.navigation.count < 1 && self.items.count > 0)
		return 1;
	else
		return self.navigation.count;
}

/// Returns the text for the header in the section.
- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	if (self.navigation.count < 1)
		return nil;

	return NON_NIL_STRING([self.navigation get:section]);
}

/// Returns the text for the footer in the section.
- (NSString *)tableView:(UITableView *)tableView
	titleForFooterInSection:(NSInteger)section
{
	return nil;
}

/** Gets the height for a section header view.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForHeaderInSection:(NSInteger)section
{
	return self.navigation.count ? _DEFAULT_SECTION_HEIGHT : 0;
}

/** Gets the height for a section footer view.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForFooterInSection:(NSInteger)section
{
	return 0;
}

/** Returns the height for a specific row.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BICategory_item *item = [self get_category:indexPath];
	return [BISearch_cell height_for_item:item
		width:self.view.bounds.size.width show_distance:self.location != nil];
}

/** Creates a cell presentation for the table.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"BISearch_view_controller_cell";

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[BISearch_cell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];
	}

	BICategory_item *item = [self get_category:indexPath];
	BISearch_cell *search_cell = (BISearch_cell*)cell;
	search_cell.user_location = self.location;
	search_cell.item = item;
	if (!item)
		[api_ request_page_for_row:indexPath.row];

	return cell;
}

/** Returns the number of items in the table's section.
 */
- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section
{
	if (self.navigation.count < 1)
		return self.items.count;

	NSArray *items = [self.items get:section];
	if ([items respondsToSelector:@selector(count)]) {
		return items.count;
	} else {
		DLOG(@"Looks like the items array doesn't have sections");
		return 0;
	}
}

/** User interacted with a row, push a new controller.
 */
- (void)tableView:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	BICategory_item *item = [self get_category:indexPath];

	UIViewController *controller = nil;

	if (API_SEARCH_MORE_PEOPLE == item.type ||
			API_SEARCH_MORE_ENTITIES == item.type) {
		/// Special search case, create new controller with paginated version.
		BISearch_view_controller *search = [BISearch_view_controller new];
		[search paginate_search:API_SEARCH_MORE_PEOPLE == item.type ?
			API_SEARCH_PEOPLE : API_SEARCH_ENTITIES total_count:item.id_
			initial_search:api_];
		controller = [search autorelease];
	} else {
		controller = [item get_controller];
	}

	controller.hidesBottomBarWhenPushed = YES;
	if (controller)
		[self.navigationController pushViewController:controller animated:YES];

	// Show a lock to the user if the data is still loading.
	if (!item) {
		[UIView animateWithDuration:_FADE_IN_SPEED delay:0
			DEFAULT_ANIM_OPTIONS | UIViewAnimationOptionBeginFromCurrentState
			animations:^{ lock_.alpha = 1; } completion:^(BOOL finished) {
				[UIView animateWithDuration:_FADE_OUT_SPEED
					delay:_LOCK_SECONDS DEFAULT_ANIM_OPTIONS
					animations:^{ lock_.alpha = 0; } completion:nil];}];
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
