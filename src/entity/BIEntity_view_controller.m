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

#import "entity/BIEntity_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "categories/UINavigationBar+Bidrasil.h"
#import "entity/BIButton_cell.h"
#import "entity/BIMap_view_controller.h"
#import "entity/BIPair_cell.h"
#import "entity/BISubtitle_cell.h"
#import "global/BIGlobal.h"
#import "global/BIMail_view_controller.h"
#import "model/BIAddressbook_source.h"
#import "model/BIContact_info.h"
#import "model/BIEntity_item.h"
#import "model/BIInteractive_row.h"
#import "model/BIRelated_person.h"
#import "model/BIRelationship.h"
#import "model/BIRelationship_item.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSObject+ELHASO.h"
#import "UIActivity.h"
#import "UILabel+ELHASO.h"
#import "UIView+ELHASO.h"


#define _TAB_DATA					0
#define _TAB_PEOPLE					1
#define _TAB_RELATED				2
#define _FADE_OUT_SPEED				3
#define _ROW_HEIGHT					44

#define _DEFAULT_ANIM_OPTIONS \
	options:UIViewAnimationOptionCurveEaseInOut | \
		UIViewAnimationOptionTransitionNone | \
		UIViewAnimationOptionAllowUserInteraction



@interface BIEntity_view_controller ()
- (void)resize_table;
- (void)update_header_tab_visibility:(BOOL)animated;

- (void)ask_yes_no:(NSString*)title text:(NSString*)text
	perform:(void (^)(BOOL accepted))block;

- (void)select_option:(NSArray*)rows title:(NSString*)title
	perform:(void (^)(int selected_button))block;

// Methods for data tab file.
- (void)update_local_items_data;

- (CGFloat)tab_data:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath;

- (UITableViewCell*)tab_data:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath;

- (NSInteger)tab_data:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section;

- (NSInteger)tab_data_number_of_sections;

- (void)tab_data:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

// Methods for people tab file.
- (CGFloat)tab_people:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath;

- (UITableViewCell*)tab_people:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)tab_people:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

// Methods for the related tab file.
- (int)tab_related_rows_count;
- (void)update_local_items_related;

- (CGFloat)tab_related:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath;

- (UITableViewCell*)tab_related:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath;

- (NSInteger)tab_related:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section;

- (NSInteger)tab_related_number_of_sections;

- (NSString *)tab_related:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section;

- (void)tab_related:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

@end


@implementation BIEntity_view_controller

@synthesize item = item_;
@synthesize works_for_relationship = works_for_relationship_;

#pragma mark -
#pragma mark Methods

- (void)loadView
{
	[super loadView];

	LASSERT(did_set_api_, @"You should set the api before displaying this");

	LASSERT(!header_, @"Double initialization");
	if (self.item_title.length) {
		header_ = [[BITabbed_header alloc] initWithFrame:self.view.bounds];
		header_.text = self.item_title;
		[header_ set_tabs:[NSArray arrayWithObjects:_(VIEWER_TAB_DATA),
			_(VIEWER_TAB_PEOPLE), _(VIEWER_TAB_RELATED), nil]];
		if (API_PERSON == api_.type)
			[header_ show_tab:NO num:_TAB_PEOPLE animated:NO];

		if (self.item)
			[self update_header_tab_visibility:NO];
		header_.selected_tab = last_tab_;
		header_.delegate = self;
		[self.view addSubview:header_];
	}
}

- (void)unload_view
{
	header_.delegate = nil;
	[super unload_view];
	[header_ removeFromSuperview];
	[header_ release];
	header_ = nil;
}

- (void)dealloc
{
	wait_for_ui(^{ [self unload_view]; });
	UNLOAD_OBJECT(ask_block_);
	UNLOAD_OBJECT(action.block_);
	[works_for_relationship_ release];
	[action.sheet_ release];
	[item_ release];
	[api_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIEntity_view_controller {api:%@",
		api_];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([api_ start]) {
		[self show_connecting_label];
	} else {
		DLOG(@"Already loaded data for %d type %d",
			self.item.id_, self.item.type);
	}

	[header_ resize_to_width:self.view.bounds.size.width];
	[self resize_table];
}

/** Modifies the frame of the tableView based on the height of the header_.
 * You can call this from anywere to update the position of the table.
 */
- (void)resize_table
{
	CGRect rect = self.view.frame;
	rect.origin.y = header_.bounds.size.height;
	rect.size.height -= rect.origin.y;
	self.tableView.frame = rect;
}

/** Sets the API entry for this view controller.
 * The api should be set only once. It will start fetching when the view is
 * viewed, not before.
 */
- (void)set_api:(API_TYPE)type num:(int)num
{
	LASSERT(API_ENTITY == type || API_PERSON == type, @"Incorrect type");
	[api_ cancel];
	[api_ release];
	api_ = [[BIAPI_entry alloc] init_with_entry:type item:num delegate:self];
	did_set_api_ = YES;
}

/** This will cancel the API, create a new one and start a network fetch.
 * Used by the retry button action when something fails and the user is allowed
 * to reinitiate the connection. Unlike other force_api_refresh methods, this
 * calls first set_ui_labels. Why? Because inside this view controller we
 * hijacked the connecting_label_ to show a custom error. If we simply
 * redisplay it when reconnecting, the previous error message will show! By
 * calling set_ui_labels we force the regeneration of the default connection
 * dialog.
 */
- (void)force_api_refresh
{
	[self set_api:api_.type num:api_.id_];
	if ([api_ start]) {
		[self set_ui_labels];
		[self show_connecting_label];
	}
}

/** Override the default plain stype with the groupped one.
 */
- (UITableViewStyle)table_style
{
	return UITableViewStyleGrouped;
}

/** Regenerates the contents of the items array based on the selected tab.
 * The items array will be populated with some precalculated values that make
 * it easier for the tableview methods to deal with the numerous types of cells
 * and views. After this call, the items array may end up being nil, or have
 * values.
 *
 * For the _TAB_DATA, there will be three sections, the first being the
 * address, the second the contacts, the third being aciton buttons. The items
 * array will be set to single items containing BIInteractive_row objects for
 * the contact rows (the other sections are static, hardcoded).
 *
 * In the case of _TAB_RELATED, the deep nested hierarchy of relationships is
 * flattened into simpler two level arrays so that the groups and titles for
 * each section are easier to get.
 */
- (void)update_local_items
{
	switch (header_.selected_tab) {
		case _TAB_DATA: [self update_local_items_data]; break;
		case _TAB_RELATED: [self update_local_items_related]; break;

		default:
			self.items = nil;
			break;
	}
}

/** Updates the visibility of the header tabs.
 * Pass YES if you want to animate the change. Usually you want to animate the
 * changes only if the view is being updated after a download, not after
 * setting up the screen in loadView. Also, if you are on a person, you never
 * want animation to remove the people's tab.
 */
- (void)update_header_tab_visibility:(BOOL)animated
{
	// Decide if we have to hide additional headers due to changes.
	if ([self tab_related_rows_count] < 1)
		[header_ show_tab:NO num:_TAB_RELATED animated:animated];

	// Hide people tab for entities.
	if (API_ENTITY == api_.type && self.item.people.count < 1)
		[header_ show_tab:NO num:_TAB_PEOPLE animated:animated];
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
#pragma mark Row interaction

/** The user wants to share the thing with the world or tell somebody something.
 * If the to parameter is nil, this creates a modal view to compose an email
 * with a link to the current item and VCF card. If the to parameter is valid,
 * an empty mail will be prepared to that person.
 */
- (void)send_email:(NSString*)to
{
	if (![BIMail_view_controller canSendMail]) {
		[self show_alert:_(ERROR_NOMAIL_TITLE) text:_(ERROR_NOMAIL_MESSAGE)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	NSString *subject = to.length ? @"" :
		_F(MAIL_FORMAT_SUBJECT, [self.item full_name]);
	NSString *body = to.length ? @"" : _F(MAIL_FORMAT_BODY,
		self.item.share_url.length ? self.item.share_url : [api_ html_url]);

	BIMail_view_controller *mail = [BIMail_view_controller new];
	mail.mailComposeDelegate = self;
	if (to.length)
		[mail setToRecipients:[NSArray arrayWithObject:to]];
	[mail setSubject:subject];
	[mail setMessageBody:body isHTML:NO];
	[UINavigationBar show_bidrasil:NO];
	[self presentModalViewController:mail animated:YES];
	[mail release];
}

/** Asks the user first if she wants to call the phone number.
 * If something goes wrong, shows an alert to the user.
 */
- (void)prepare_phone:(NSString*)phone
{
	[self ask_yes_no:_(PHONE_ALERT_TITLE) text:_F(PHONE_ALERT_MESSAGE, phone)
		perform:^(BOOL accepted){
			if (accepted)
				[self open_url:@"tel://" address:phone
					error_title:_(PHONE_ERROR_TITLE)
					error_text:_(PHONE_ERROR_MESSAGE)];
		}];
}

/** Asks the user first if she wants to open a web page.
 * If something goes wrong, shows an alert to the user.
 */
- (void)prepare_web:(NSString*)web
{
	[self ask_yes_no:_(WEB_ALERT_TITLE) text:_F(WEB_ALERT_MESSAGE, web)
		perform:^(BOOL accepted){
			if (accepted)
				[self open_url:@"" address:web
					error_title:_(WEB_ERROR_TITLE)
					error_text:_(WEB_ERROR_MESSAGE)];
		}];
}

#pragma mark -
#pragma mark UIAlertView

/** Shows an alert asking the user to accept something, a question maybe.
 * Pass the block you want to run when the user touches one of the buttons.
 */
- (void)ask_yes_no:(NSString*)title text:(NSString*)text
	perform:(void (^)(BOOL accepted))block;
{
	LASSERT(!ask_block_, @"No reentrancy support!");
	ask_block_ = [block copy];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
		message:text delegate:self cancelButtonTitle:_(BUTTON_CANCEL)
		otherButtonTitles:_(BUTTON_ACCEPT), nil];
	[alert show];
	[alert release];
}

/** User touched a button.
 * Pass the information to the block and release it.
 */
- (void)alertView:(UIAlertView *)alertView
	clickedButtonAtIndex:(NSInteger)buttonIndex
{
	const BOOL did_accept = alertView.cancelButtonIndex != buttonIndex;

	void (^temp_block)(BOOL accepted) = ask_block_;
	ask_block_ = nil;
	temp_block(did_accept);
	[temp_block release];
}

/** User cancelled the alert.
 * Pass the information to the block and release it.
 */
- (void)alertViewCancel:(UIAlertView *)alertView
{
	void (^temp_block)(BOOL accepted) = ask_block_;
	ask_block_ = nil;
	temp_block(NO);
	[temp_block release];
}

#pragma mark -
#pragma mark UIActionSheet

/** If there is an action sheet, it will be cancelled.
 * This is a hook helper for the iPad, where pressing the section
 * popover should cancel the share action.
 */
- (void)cancel_previous_action_sheet
{
	[action.sheet_ dismissWithClickedButtonIndex:action.sheet_.cancelButtonIndex
		animated:NO];
}

/** Builds and presents an action sheet with content sharing options.
 */
- (void)select_option:(NSArray*)rows title:(NSString*)title
	perform:(void (^)(int selected_button))block
{
	LASSERT(rows.count > 0, @"Trying to pick between no rows?");
	[self cancel_previous_action_sheet];
	[action.block_ release];
	action.block_ = [block copy];

	[action.sheet_ release];
	action.sheet_ = [[UIActionSheet alloc]
		initWithTitle:title delegate:self cancelButtonTitle:nil
		destructiveButtonTitle:nil otherButtonTitles:nil];

	for (NSString *text in rows) {
		LASSERT([text isKindOfClass:[NSString class]], @"Pass text please");
		[action.sheet_ addButtonWithTitle:text];
	}

	[action.sheet_ addButtonWithTitle:_(BUTTON_CANCEL)];
	action.sheet_.cancelButtonIndex = action.sheet_.numberOfButtons - 1;
	[action.sheet_ showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet
	clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.cancelButtonIndex == buttonIndex) {
		DLOG(@"Actionsheet cancelled.");
		return;
	}

	action.block_(buttonIndex);
}

- (void)actionSheet:(UIActionSheet*)actionSheet
	willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	LASSERT(action.sheet_, @"Uh oh, not tracking properly the action sheets.");
	[action.sheet_ release]; action.sheet_ = nil;
}

#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate

/** Forces dismissing of the view, only logging the error, not dealing with it.
 */
- (void)messageComposeViewController:
	(MFMessageComposeViewController*)controller
	didFinishWithResult:(MessageComposeResult)result
{
	DLOG(@"Did SMS fail? %d", result);
	[UINavigationBar show_bidrasil:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark BIItem_receiver protocol

/** Receives notifications of new items to show.
 * Since we are expecting an update_entity: message, if we get called through
 * here it means there was an error.
 */
- (void)update_items:(NSArray*)items navigation:(NSArray*)navigation
	qi_titles:(NSArray*)qi_titles qi_numbers:(NSArray*)qi_numbers
{
	BLOCK_UI();
	LASSERT(!navigation, @"Unexpected parameter");
	LASSERT(items, @"Null items?");
	LASSERT(1 == items.count, @"We were expecting a single object");

	[self show_error_label:[items get:0]];
	[self show_retry_button:@selector(force_api_refresh)];
}

/** Got data from the entity.
 * Reloads the table and displays it.
 */
- (void)update_entity:(BIEntity_item*)entity
{
	BLOCK_UI();
	[self hide_connecting_label];

	if ([entity isKindOfClass:[BIEntity_item class]]) {
		self.item = entity;
		[self update_header_tab_visibility:YES];
		[self update_local_items];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
	} else {
		[self show_error_label:entity];
		[self show_retry_button:@selector(force_api_refresh)];
	}
}

#pragma mark -
#pragma mark BITabbed_header_delegate

- (BOOL)header_tab_touched:(int)number
{
	if (!self.item)
		return NO;

	last_tab_ = number;
	DLOG(@"Viewing tab %d for entity %d type %d",
		number, self.item.id_, self.item.type);
	[self after:0 perform:^{
			[self update_local_items];
			[self.tableView reloadData];
			[self.tableView flashScrollIndicators];
		}];
	return YES;
}

#pragma mark -
#pragma mark Rotation handlers

#ifdef ALLOWS_LANDSCAPE
- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

/** Animate the top view.
 */
- (void)willAnimateRotationToInterfaceOrientation:
	(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
	[header_ resize_to_width:[self will_rotate_to_width:orientation]];
	[self resize_table];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	[self.tableView reloadData];
}
#endif

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch (header_.selected_tab) {
		case _TAB_DATA:
			return [self tab_data:tableView heightForRowAtIndexPath:indexPath];

		case _TAB_PEOPLE:
			return [self tab_people:tableView
				heightForRowAtIndexPath:indexPath];

		case _TAB_RELATED:
			return [self tab_related:tableView
				heightForRowAtIndexPath:indexPath];

		default: return _ROW_HEIGHT;
	}
}

/** Returns the correct cell.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch (header_.selected_tab) {
		case _TAB_DATA:
			return [self tab_data:tableView cellForRowAtIndexPath:indexPath];
		case _TAB_PEOPLE:
			return [self tab_people:tableView cellForRowAtIndexPath:indexPath];
		case _TAB_RELATED:
			return [self tab_related:tableView cellForRowAtIndexPath:indexPath];
		default:
			LASSERT(NO, @"Not implemented?");
			break;
	}

	return nil;
}

- (NSInteger)tableView:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
	switch (header_.selected_tab) {
		case _TAB_DATA:
			return [self tab_data:tableView numberOfRowsInSection:section];

		case _TAB_PEOPLE:
			return self.item.people.count;

		case _TAB_RELATED:
			return [self tab_related:tableView numberOfRowsInSection:section];
	}

	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	switch (header_.selected_tab) {
		case _TAB_DATA: return [self tab_data_number_of_sections];
		case _TAB_PEOPLE: return 1;
		case _TAB_RELATED: return [self tab_related_number_of_sections];
	}

	return 0;
}

/** Returns the name of a section.
 * This is only used by the related tab to group relationships.
 */
- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	if (_TAB_RELATED == header_.selected_tab)
		return [self tab_related:tableView titleForHeaderInSection:section];
	else
		return nil;
}

/** User interacted with a row, push a new controller.
 */
- (void)tableView:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch (header_.selected_tab) {
		case _TAB_DATA:
			[self tab_data:tableView didSelectRowAtIndexPath:indexPath];
			break;

		case _TAB_PEOPLE:
			[self tab_people:tableView didSelectRowAtIndexPath:indexPath];
			break;

		case _TAB_RELATED:
			[self tab_related:tableView didSelectRowAtIndexPath:indexPath];
			break;

		default:
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
	}
}

#define _INCLUDE_DATA
#include "entity/BIEntity_view_controller_data.m"
#define _INCLUDE_PEOPLE
#include "entity/BIEntity_view_controller_people.m"
#define _INCLUDE_RELATED
#include "entity/BIEntity_view_controller_related.m"

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
