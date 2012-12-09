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

#import "index/BIIndex_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "global/BIGPS.h"
#import "global/BIGlobal.h"
#import "global/BITitle_header.h"
#import "index/BIIndex_cell.h"
#import "index/BISearch_view_controller.h"
#import "model/BICategory_item.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSNotificationCenter+ELHASO.h"
#import "UIImageView+ELHASO.h"
#import "UILabel+ELHASO.h"

#import <QuartzCore/CALayer.h>


#define _FADE_IN_SPEED					0.3
#define _FADE_OUT_SPEED					1
#define _LOCK_SECONDS					1
#define _SEARCH_FADE					0.3
#define _DEFAULT_SECTION_HEIGHT			22
#define _SEARCH_BAR_HEIGHT				45


@interface BIIndex_view_controller ()
- (void)set_ui_labels;
- (void)show_search_options:(BOOL)show;
@end


@implementation BIIndex_view_controller

@synthesize navigation = navigation_;

- (void)loadView
{
	[super loadView];

	self.view.frame = self.view.bounds;

	self.tableView.sectionIndexMinimumDisplayRowCount = 30;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	LASSERT(!lock_, @"Double initialization");
	UIImageView *lock_view = [UIImageView imageNamed:@"lock-icon.png"];
	lock_view.layer.shadowOffset = CGSizeMake(3, 3);
	lock_view.layer.shadowOpacity = 1;
	lock_ = [[UILabel round_text:_(CONTENT_NOT_LOADED_YET)
		bounds:CGRectMake(0, 0, 200, 200) fit:YES radius:20
		view:lock_view] retain];

	lock_.center = self.view.center;
	lock_.userInteractionEnabled = NO;
	lock_.alpha = 0;
	[self.view addSubview:lock_];

	// Build a dummy header which can be expaned and customized.
	UIView *dummy_header = [[UIView alloc] initWithFrame:self.view.bounds];
	CGRect rect = dummy_header.frame;
	rect.size.height = 0;
	dummy_header.frame = rect;
	self.tableView.tableHeaderView = dummy_header;
	[dummy_header release];

	[self loadView_search];
	[self loadView_title];

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center refresh_observer:self selector:@selector(refresh_api:)
		name:BIData_langcode_did_change object:nil];

	[center refresh_observer:self selector:@selector(refresh_api:)
		name:BIUI_langcode_did_change object:nil];
}

/** Creates the header for the indices which contain a title.
 * You may override this in subclasses to prevent the search from appearing.
 */
- (void)loadView_title
{
	if (self.item_title.length) {
		header_ = [[BITitle_header alloc] initWithFrame:self.view.bounds];
		header_.text = self.item_title;
		[self add_to_table_header:header_];
	}
}

/** Creates the search widget and adds it to the table header.
 * You may override this in subclasses to prevent the search from appearing.
 */
- (void)loadView_search
{
	// Grab hold of the GPS object.
	gps_ = [BIGPS get];
	gps_.delegate = self;

	const BOOL hide = (!(api_ && API_CATEGORY == api_.type && 0 == api_.id_));

	// The search widget itself. Always added with zero height.
	search_bar_ = [[UISearchBar alloc]
		initWithFrame:CGRectMake(0, hide ? -_SEARCH_BAR_HEIGHT: 0,
			320, _SEARCH_BAR_HEIGHT)];
	search_bar_.tintColor = [UIColor navigation_bar_green_2];
	search_bar_.delegate = self;
	if (hide)
		[self.tableView.tableHeaderView addSubview:search_bar_];
	else
		[self add_to_table_header:search_bar_];

	// Special semi-translucent pane containing other UI widgets.
	CGRect rect = self.tableView.bounds;
	rect.origin.y = search_bar_.bounds.size.height;
	search_options_ = [[UIView alloc] initWithFrame:rect];
	search_options_.alpha = 0;
	search_options_.autoresizingMask = FLEXIBLE_SIZE;
	search_options_.backgroundColor = [[UIColor blackColor]
		colorWithAlphaComponent:0.8];
	[self.view addSubview:search_options_];

	// The resizeable label specifying the current switch status.
	location_label_ = [[UILabel alloc] initWithFrame:CGRectZero];
	location_label_.autoresizingMask = UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleHeight |
		UIViewAutoresizingFlexibleBottomMargin;
	location_label_.numberOfLines = 0;
	location_label_.backgroundColor = [UIColor clearColor];
	location_label_.textColor = [UIColor lightGrayColor];
	location_label_.shadowColor = [UIColor darkGrayColor];
	location_label_.shadowOffset = CGSizeMake(0, -1);
	[search_options_ addSubview:location_label_];

	// The switch to turn on/off location search.
	location_switch_= [[UISwitch alloc] initWithFrame:CGRectZero];
	location_switch_.autoresizingMask =
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;
	location_switch_.on = [BIGlobal get_location_search];
	[location_switch_ addTarget:self action:@selector(update_search_label:)
		forControlEvents:UIControlEventValueChanged];
	[search_options_ addSubview:location_switch_];

	// A small label to specify what the switch is for.
	switch_label_ = [[UILabel alloc] initWithFrame:CGRectZero];
	switch_label_.autoresizingMask = UIViewAutoresizingFlexibleHeight |
		UIViewAutoresizingFlexibleBottomMargin;
	switch_label_.textAlignment = UITextAlignmentCenter;
	switch_label_.font = [UIFont boldSystemFontOfSize:13];
	switch_label_.backgroundColor = [UIColor clearColor];
	switch_label_.textColor = [UIColor whiteColor];
	switch_label_.shadowColor = [UIColor darkGrayColor];
	switch_label_.shadowOffset = CGSizeMake(0, -1);
	[search_options_ addSubview:switch_label_];

	// Reset the labels of the widgets.
	[self set_ui_labels];

	[self show_search_options:NO];
}

- (void)unload_view
{
	[super unload_view];
	[gps_ stop];
	UNLOAD_VIEW(lock_);
	UNLOAD_VIEW(header_);
	UNLOAD_VIEW(search_bar_);
	UNLOAD_VIEW(search_options_);
	UNLOAD_VIEW(location_label_);
	UNLOAD_VIEW(location_switch_);
	UNLOAD_VIEW(switch_label_);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	gps_.delegate = nil;
	search_bar_.delegate = nil;
	wait_for_ui(^{ [self unload_view]; });
	[cached_index_titles_ release];
	[api_ cancel];
	[api_ release];
	[navigation_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIIndex_view_controller {api:%@",
		api_];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Adjust the position of some graphical elements, depends on orientation.
	BOOL landscape =self.view.bounds.size.width > self.view.bounds.size.height;
	if (landscape) {
		location_label_.frame = CGRectMake(112, 0, 368, 61);
		location_switch_.frame = CGRectMake(10, 20, 94, 27);
		switch_label_.frame = CGRectMake(10, 0, 94, 21);
	} else {
		location_label_.frame = CGRectMake(112, 0, 208, 102);
		location_switch_.frame = CGRectMake(10, 35, 94, 27);
		switch_label_.frame = CGRectMake(10, 0, 94, 35);
	}

	if ([api_ start]) {
		[self show_connecting_label];
	} else {
		DLOG(@"Already loaded data for %d type %d",
			api_.id_, api_.type);
	}

	// If there is a header, we might need to update its size if you rotated.
	if (!header_)
		return;

	[header_ resize_to_width:self.view.bounds.size.width];
	[self refresh_table_header];
}

/** Adds to an existing tableHeaderView another subview.
 * The new subview is appended to the bottom.
 */
- (void)add_to_table_header:(UIView*)view
{
	UIView *base = self.tableView.tableHeaderView;
	LASSERT(base, @"Table base header should be available");
	CGRect rect = view.frame;
	rect.origin.y = base.bounds.size.height;
	view.frame = rect;
	rect = base.frame;
	rect.size.height += view.bounds.size.height;
	base.frame = rect;
	[base addSubview:view];

	[self refresh_table_header];
}

/** Sets the API entry for this view controller.
 * The api should be set only once. It will start fetching when the view is
 * viewed, not before.
 */
- (void)set_api:(API_TYPE)type num:(int)num
{
	[api_ cancel];
	[api_ release];
	api_ = [[BIAPI_entry alloc] init_with_entry:type item:num delegate:self];
}

/** This will cancel the API, create a new one and start a network fetch.
 * This is a special method used by the BITab_view_controller when the server
 * changes. It is also used as the retry button action when something fails and
 * the user is allowed to reinitiate the connection.
 */
- (void)force_api_refresh
{
	[self set_api:api_.type num:api_.id_];
	if ([api_ start])
		[self show_connecting_label];
}

/** The user touched the switch to change the type of search.
 * We don't care really about the sender, we read the variable from our own
 * pointer in the instance, it's there just to comply with the protocol.
 */
- (void)update_search_label:(UISwitch*)sender
{
	if (location_switch_.on) {
		// Turn on location, if it was not.
		if (![gps_ start])
			run_on_ui(^{
				[location_switch_ setOn:NO animated:YES];
				[self show_alert:_(SEARCH_TYPE_LOCATION)
					text:_(SEARCH_ACTIVATE_LOCATION) button:_(BUTTON_ACCEPT)];
			});
	} else {
		// Turn off location.
		[gps_ stop];
	}

	[BIGlobal set_location_search:location_switch_.on];

	location_label_.text = @"";
	location_label_.alpha = 0;
	location_label_.text = location_switch_.on ?
		_(SEARCH_TYPE_LOCATION) : _(SEARCH_TYPE_WORDS);

	[UIView animateWithDuration:_SEARCH_FADE delay:0
		DEFAULT_ANIM_OPTIONS
		animations:^{ location_label_.alpha = 1; } completion:nil];
}

/** Called when the user changes globally the content language.
 * We only need to refresh the api. Setting it again will clean its data, and
 * the next time the user views the view it will fetch new stuff automatically.
 */
- (void)refresh_api:(NSNotification*)notification
{
	run_on_ui(^{
			DLOG(@"refreshing api %@", notification);
			[self set_api:api_.type num:api_.id_];
			self.items = nil;
			[self.tableView reloadData];
			[self set_ui_labels];
		});
}

/** Refreshes user interface labels.
 * Usually called from loadView or from a language change callback.
 */
- (void)set_ui_labels
{
	[super set_ui_labels];
	run_on_ui(^{
			location_label_.text = location_switch_.on ?
				_(SEARCH_TYPE_LOCATION) : _(SEARCH_TYPE_WORDS);
			switch_label_.text = _(SWITCH_LOCATION_LABEL);
			// It is unlikely we get the refresh events while typing a search,
			// so simply assume we can change the text to the touch version.
			search_bar_.placeholder = _(SEARCH_PLACEHOLDER_TOUCH);

			// Ugly hack to change language of cancel button.
			for (UIView *view in search_bar_.subviews) {
				if ([view respondsToSelector:@selector(setTitle:forState:)]) {
					UIButton *b = (UIButton*)view;
					[b setTitle:_(BUTTON_CANCEL) forState:UIControlStateNormal];
					break;
				}
			}
		});
}

/** Increases the size of the header the specified amount.
 * This method is used to counter the effect of search_bar_ having a negative
 * vertical origin. Used at least in searchBarShouldBeginEditing and
 * scrollViewDidEndDragging.
 */
- (void)resize_header:(int)offset
{
	if (offset < 1)
		return;

	// Resize the tableHeaderView the specified offset amount.
	UIView *base = self.tableView.tableHeaderView;
	CGRect rect = base.frame;
	rect.size.height += offset;
	base.frame = rect;
	// Now iterate through all the subviews to move them the offset amount.
	for (UIView *view in base.subviews) {
		rect = view.frame;
		rect.origin.y += offset;
		view.frame = rect;
	}
}

#pragma mark -
#pragma mark BISerialization_protocol

- (NSArray*)get_serialization_tuple
{
	if (!api_)
		return nil;

	return [NSArray arrayWithObjects:NON_NIL_STRING(self.item_title),
		[NSNumber numberWithInt:api_.type],
		[NSNumber numberWithInt:api_.id_], nil];
}

#pragma mark -
#pragma mark Rotation handlers

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#ifdef ALLOWS_LANDSCAPE
/** Animate the table header view if it exists.
 * Due to how the SDK works, the table header view can't be animated smoothly,
 * and in order to resize it is a pain, since it doesn't receive resize events.
 * So we have to manually figure out the new horizontal resolution, call the
 * resize methods on the BITitle_header and finally force a reasignment of the
 * table header view so the changes are visible. What a pain.
 */
- (void)willAnimateRotationToInterfaceOrientation:
	(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
	if (!header_)
		return;

	[header_ resize_to_width:[self will_rotate_to_width:orientation]];
	[self refresh_table_header];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	[self.tableView reloadData];
}
#endif

#pragma mark -
#pragma mark BIItem_receiver protocol

/** Receives notifications of new items to show.
 * The specified items will be associated with the view controller. This
 * updates the whole list. We won't be storing a pointer to the navigation,
 * because we want to filter 'self' items, this is, navigation categories which
 * are ourselves. Otherwise the GUI will end up with infinite recursion.
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
		[self show_retry_button:@selector(force_api_refresh)];

	// Adapt the quick index entries to the amount of items.
	const int total_items = self.items.count;
	NSRange range = { 0, 0 };
	for (NSNumber *number in qi_numbers) {
		if ([number intValue] >= total_items)
			break;
		else
			range.length++;
	}

	if (qi_numbers.count == range.length) {
		self.qi_titles = qi_titles;
		self.qi_numbers = qi_numbers;
	} else {
		// Ok, filter the items.
		self.qi_titles = [qi_titles subarrayWithRange:range];
		self.qi_numbers = [qi_numbers subarrayWithRange:range];
		DLOG(@"The quick_index pointed to entries bigger than our items!");
		range.location = range.length;
		range.length = qi_numbers.count - range.location;
		DEV_LOG(@"Table has %d items, we had to remove the following indices "
			@"out of range %@ for %@", total_items,
			[[qi_numbers subarrayWithRange:range]
				componentsJoinedByString:@", "],
			[[qi_titles subarrayWithRange:range]
				componentsJoinedByString:@", "]);
	}

	// Filter ourselves from the navigation.
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:navigation.count];
	for (BICategory_item *item in navigation)
		if (api_.type != item.type || api_.id_ != item.id_)
			[valid addObject:item];

	self.navigation = valid;

	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

/** Tells us that the BIAPI_entry has updated a range of the items.
 * Due to the quick index, we have to transform the flat indices into
 * hierarchichal versions for the table to work. A waste, but that's how it
 * goes.
 */
- (void)update_range:(NSArray*)indices
{
	if (self.qi_numbers.count) {
		NSMutableArray *transformed = [indices get_holder];
		int section = 1;
		int pointer = 0;
		int offset = [[self.qi_numbers get:pointer++] intValue];
		for (NSIndexPath *flat in indices) {
			const int flat_row = flat.row;
			// Search for the biggest offset below current value.
			while (pointer < self.qi_numbers.count) {
				NSNumber *potential_offset = [self.qi_numbers get:pointer];
				LASSERT(potential_offset, @"Uh oh");
				const int potential = [potential_offset intValue];
				if (potential > flat_row)
					break;
				offset = potential;
				section++;
				pointer++;
			}
			[transformed addObject:[NSIndexPath
				indexPathForRow:flat_row - offset inSection:section]];
		}
		//DLOG(@"Transformed indices from %@ to %@", indices, transformed);
		indices = transformed;
	}

	[self.tableView reloadRowsAtIndexPaths:indices
		withRowAnimation:UITableViewRowAnimationFade];
}

/** Returns the NSIndexPath section for the update_range: method.
 */
- (int)get_item_section
{
	return 1;
}

/** Modifies the visibility of the search options panel.
 * The visibility is done with a fade. This method also disables or enables the
 * scrolling of the table.
 */
- (void)show_search_options:(BOOL)show
{
	self.tableView.scrollEnabled = !show;

	[search_bar_ setShowsCancelButton:show animated:YES];

	search_bar_.placeholder = show ?
		_(SEARCH_PLACEHOLDER_TYPE) : _(SEARCH_PLACEHOLDER_TOUCH);

	// Only on iOS 5 we can support hidding the table for the voiceover users.
	const BOOL update_table_accessibility = [self.tableView
		respondsToSelector:@selector(setAccessibilityElementsHidden:)];

	[UIView animateWithDuration:_SEARCH_FADE delay:0
		DEFAULT_ANIM_OPTIONS | UIViewAnimationOptionBeginFromCurrentState
		animations:^{ search_options_.alpha = show ? 1 : 0; }
		completion:^(BOOL finished) {
			if (update_table_accessibility)
				self.tableView.accessibilityElementsHidden = show;
			UIAccessibilityPostNotification(
				UIAccessibilityScreenChangedNotification, nil);
		}];

	// Start/stop the gps upadtes if necessary.
	if (!show)
		[gps_ stop];
	else if (location_switch_.on)
		[gps_ start];
}

#pragma mark -
#pragma mark UISearchBar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	DLOG(@"searchBarShouldBeginEditing");
	const int offset = abs(search_bar_.frame.origin.y);
	[self resize_header:offset];
	[self show_search_options:YES];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	DLOG(@"searchBarShouldEndEditing");
	[self show_search_options:NO];
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	DLOG(@"searchBarCancelButtonClicked");
	[self show_search_options:NO];
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	DLOG(@"searchBarSearchButtonClicked");
	// Disallow location search if we don't have an idea of where we are.
	if (location_switch_.on && (!gps_.last_pos ||
				gps_.last_pos.horizontalAccuracy < 0.5 ||
				gps_.last_pos.horizontalAccuracy > 8000)) {

		[self show_alert:_(SEARCH_TYPE_LOCATION) text:_(SEARCH_NO_POS)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	if (searchBar.text.length) {
		DLOG(@"Searching for %@", searchBar.text);
		BISearch_view_controller *c = [BISearch_view_controller new];
		c.hidesBottomBarWhenPushed = YES;
		if (location_switch_.on)
			c.location = gps_.last_pos;
		[c set_search:searchBar.text];
		[self.navigationController pushViewController:c animated:YES];
		[c release];
	}
	[self searchBarCancelButtonClicked:searchBar];
}

#pragma mark -
#pragma mark BIGPS_delegate

- (void)gps_denied
{
	DLOG(@"BIIndex_view_controller received gps denial");
	[location_switch_ setOn:NO animated:YES];
	[self show_alert:_(SEARCH_TYPE_LOCATION)
		text:_(SEARCH_ACTIVATE_LOCATION) button:_(BUTTON_ACCEPT)];
	[self update_search_label:nil];
}

#pragma mark -
#pragma mark UITableView delegates

/** Detects scrolliing on the table, which hides the search options.
 * This hook is necessary for the voiceover to correctly release the search
 * options screen if the focus has managed to go bellow the view and is
 * iterating over the table's cells. This can happen before iOS 5.x due to
 * voiceover not supporting the setAccessibilityElementsHidden: methods.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (search_options_.alpha > 0)
		[self searchBarCancelButtonClicked:search_bar_];
}

/** Controlls the end of drag user interaction.
 * Due to our trick hidding the search_bar_ in the tableHeaderView, we want to
 * detect how much the user has scrolled the table up to reset the
 * tableHeaderView. This has to be done in two steps, the second happening in
 * the scrollViewWillBeginDecelerating: method. First, this method calculates
 * how many pixels has the user dragged the table above, and then substracts
 * this amount from the hidden pixels the search_bar_ widget still has to go to
 * be completely visible.
 *
 * If the user has moved the table far enough, the cancel_bounce_ variable is
 * turned on for the scrollViewWillBeginDecelerating: method to work next.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
	willDecelerate:(BOOL)decelerate
{
	const CGPoint p = scrollView.contentOffset;
	if (p.y >= 0)
		return;

	const int search_bar_position = search_bar_.frame.origin.y;
	if (search_bar_position >= 0)
		return;
	const int to_move = abs(search_bar_position);
	if (to_move < 1)
		return;
	DLOG(@"Did end dragging! %0.0f", p.y);

	const int offset = MIN(abs(p.y), to_move);
	if (offset > 0) {
		cancel_bounce_ = YES;
		DLOG(@"Resetting table search offset trick %d", offset);
		[self resize_header:offset];
	}
}

/** Hooks the deceleration of the scroll to reset the bounce if needed.
 * This is the second part of scrollViewDidEndDragging:, where we check for the
 * cancel_bounce_ instance variable. If set to yes, we force a table header
 * refresh so that the table updates the size. This results in an ugly
 * non-bounce effect generated by the setContentOffset: method. It looks ugly,
 * but if we don't do it, the precalculated decelleration by the SDK will be
 * borked when we refresh the table header and suddenly the table size grows!
 * In this situation the decelleration rate doesn't match the new size and
 * there's a double uglier bounce effect.
 */
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if (cancel_bounce_) {
		DLOG(@"Cancelling bounce due to search_bar_ offset trick!");
		[self refresh_table_header];
		[scrollView setContentOffset:scrollView.contentOffset animated:YES];
		cancel_bounce_ = NO;
	}
}

/** Reverses the transformation of get_category:.
 * You usually want to convert the indexPath of a cell into a direct access
 * value for the self.items array, which is flattened. If there are no
 * quick_index attributes, this just returns the row.
 */
- (int)flatten:(NSIndexPath*)path
{
	LASSERT(0 != path.section, @"Shouldn't use flatten on this indexPath");

	if (self.qi_numbers.count) {
		NSNumber *offset = [self.qi_numbers get:path.section - 1];
		return path.row + [offset intValue];
	} else {
		return path.row;
	}
}

/** Returns the category item for the specified index path.
 * May return nils.
 */
- (BICategory_item*)get_category:(NSIndexPath*)path
{
	if (0 == path.section)
		return [self.navigation get:path.row];

	return [self.items get_non_null:[self flatten:path]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.qi_titles.count)
		return 1 + self.qi_titles.count;
	else
		return 2;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if (self.qi_titles.count < 1)
		return nil;

	if (!cached_index_titles_) {
		NSMutableArray *temp = [[NSMutableArray alloc]
			initWithCapacity:1 + self.qi_titles.count];
		[temp addObject:@" "];
		[temp addObjectsFromArray:self.qi_titles];
		cached_index_titles_ = temp;
	}
	return cached_index_titles_;
}

/// Returns the text for the header in the section.
- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	if (section && self.qi_titles.count < 1)
		return nil;

	return section ? [self.qi_titles get:section - 1] :
		_(INDEX_SECTION_RELATED);
}

/// Returns the text for the footer in the section.
- (NSString *)tableView:(UITableView *)tableView
	titleForFooterInSection:(NSInteger)section
{
	if (section)
		return nil;

	return _(INDEX_SECTION_CATEGORIES);
}

/** Gets the height for a section header view.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForHeaderInSection:(NSInteger)section
{
	if (section && self.qi_titles.count) {
		return _DEFAULT_SECTION_HEIGHT;
	} else {
		if (self.navigation.count)
			return section ? 0 : _DEFAULT_SECTION_HEIGHT;
		else
			return 0;
	}
}

/** Gets the height for a section footer view.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForFooterInSection:(NSInteger)section
{
	if (self.navigation.count)
		return section ? 0 : _DEFAULT_SECTION_HEIGHT;
	else
		return 0;
}
/** Returns the height for a specific row.
 */
- (CGFloat)tableView:(UITableView *)tableView
	heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BICategory_item *item = [self get_category:indexPath];
	return [BIIndex_cell height_for_item:item
		width:self.view.bounds.size.width];
}

/** Creates a cell presentation for the table.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"BIIndex_view_controller_cell";

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[BIIndex_cell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];
	}

	BICategory_item *item = [self get_category:indexPath];
	BIIndex_cell *index_cell = (BIIndex_cell*)cell;
	index_cell.item = item;
	if (!item)
		[api_ request_page_for_row:[self flatten:indexPath]];

	return cell;
}

/** Returns the number of items in the table's section.
 */
- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section
{
	if (0 == section)
		return self.navigation.count;

	if (self.qi_numbers) {
		NSNumber *offset1 = [self.qi_numbers get:section - 1];
		NSNumber *offset2 = [self.qi_numbers get:section];
		LASSERT(offset1, @"Couldn't get offset for first section!");
		if (offset2) {
			LASSERT([offset2 intValue] >= [offset1 intValue], @"Bad offsets");
			return MAX(0, [offset2 intValue] - [offset1 intValue]);
		} else {
#ifdef DEBUG
			if (self.items.count < [offset1 intValue]) {
				DLOG(@"Wait, section %@ points to %@, but the table only "
					"has %d items!", [self.qi_titles get:section - 1],
					offset1, self.items.count);
			}
#endif
			return MAX(0, self.items.count - [offset1 intValue]);
		}
	} else {
		return self.items.count;
	}
}

/** User interacted with a row, push a new controller.
 */
- (void)tableView:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	BICategory_item *item = [self get_category:indexPath];

	UIViewController *controller = [item get_controller];
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
