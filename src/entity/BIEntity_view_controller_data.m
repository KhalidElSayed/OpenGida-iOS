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

/** This file is included from BIEntity_view_controller. Don't compile it!
 */
#define _TAB_ROWS_JOB				0
#define _TAB_ROWS_ADDRESS			1
#define _TAB_ROWS_PHONES			2
#define _TAB_ROWS_ACTIONS			3

#define _BUTTON_SMS					0
#define _BUTTON_FACETIME			1
#define _BUTTON_EMAIL				2
#define _BUTTON_SAVE				3


#ifndef _INCLUDE_DATA
#import "entity/BIEntity_view_controller.h"
@implementation BIEntity_view_controller
#endif


/** See update_local_items.
 */
- (void)update_local_items_data
{
	NSMutableArray *valid = [NSMutableArray arrayWithCapacity:10];
	[valid addObjectsFromArray:[self.item.public_contact interactive_rows]];
	for (BIInteractive_row *row in
			[self.item.private_contact interactive_rows]) {
		row.is_private = YES;
		[valid addObject:row];
	}
	self.items = valid.count ? [NSArray arrayWithArray:valid] : nil;

	// Count now interactivity of contact for sms and facetime actions.
	[valid removeAllObjects];
	[valid addObjectsFromArray:[self.item.public_contact sms_rows]];
	[valid addObjectsFromArray:[self.item.private_contact sms_rows]];
	show_sms_button_ = valid.count > 0;

	[valid removeAllObjects];
	[valid addObjectsFromArray:[self.item.public_contact facetime_rows]];
	[valid addObjectsFromArray:[self.item.private_contact facetime_rows]];
	show_facetime_button_ = valid.count > 0;

	self.works_for_relationship = nil;
	// Use heuristics to detect if the works_for item is related to something
	// in the relationships array, so we can autolink it for the user (refs
	// #2258).
	NSString *firm_name = [self.item.works_for get:0];
	if (![firm_name isKindOfClass:[NSString class]] || firm_name.length < 1)
		return;
	// Look for a relationship with the same name as the job firm name.
	for (BIRelationship *group in self.item.relationships) {
		for (BIRelationship_item *relationship in group.items) {
			for (BIInteractive_row *row in relationship.rows) {
				if (![firm_name isEqualToString:row.data])
					continue;
				DLOG(@"Found works for relationship %@", relationship);
				self.works_for_relationship = relationship;
				return;
			}
		}
	}
}

/** Initiates a facetime with a contact, if possible.
 * If something goes wrong, shows an alert to the user.
 */
- (void)start_facetime:(BIInteractive_row*)address
{
	[self open_url:@"facetime://" address:address.data
		error_title:_(FACETIME_ERROR_TITLE)
		error_text:_(FACETIME_ERROR_MESSAGE)];
}

/** Shows the available options for facetime and lets the user pick one.
 */
- (void)prepare_facetime
{
	NSMutableArray *options = [NSMutableArray arrayWithCapacity:10];
	[options addObjectsFromArray:[self.item.public_contact facetime_rows]];
	[options addObjectsFromArray:[self.item.private_contact facetime_rows]];
	if (options.count < 1) {
		[self show_alert:_(FACETIME) text:_(FACETIME_NO_CONTACTS)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	if (1 == options.count) {
		[self start_facetime:[options get:0]];
		return;
	}

	NSMutableArray *texts = [NSMutableArray arrayWithCapacity:options.count];
	for (BIInteractive_row *row in options)
		[texts addObject:[NSString stringWithFormat:@"%@ %@",
			[row type_string], row.data]];

	[self select_option:texts title:_(FACETIME)
		perform:^(int selected_button) {
			BIInteractive_row *row = [options get:selected_button];
			LASSERT(row, @"Bad action sheet index?");
			[self start_facetime:row];
		}];
}

/** Opens the SMS application to send an sms.
 * If something goes wrong, shows an alert to the user.
 */
- (void)start_sms:(BIInteractive_row*)address
{
	if (![MFMessageComposeViewController canSendText]) {
		[self show_alert:_(SMS_ERROR_TITLE) text:_(SMS_ERROR_MESSAGE)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	MFMessageComposeViewController *sms =
		[[MFMessageComposeViewController alloc] init];
	sms.recipients = [NSArray arrayWithObject:address.data];
	sms.messageComposeDelegate = self;
	[UINavigationBar show_bidrasil:NO];
	[self presentModalViewController:sms animated:YES];
	[sms release];
}

/** Shows the available options for SMS and lets the user pick one.
 */
- (void)prepare_sms
{
	NSMutableArray *options = [NSMutableArray arrayWithCapacity:10];
	[options addObjectsFromArray:[self.item.public_contact sms_rows]];
	[options addObjectsFromArray:[self.item.private_contact sms_rows]];
	if (options.count < 1) {
		[self show_alert:_(SMS) text:_(SMS_NO_CONTACTS)
			button:_(BUTTON_ACCEPT)];
		return;
	}

	if (1 == options.count) {
		[self start_sms:[options get:0]];
		return;
	}

	NSMutableArray *texts = [NSMutableArray arrayWithCapacity:options.count];
	for (BIInteractive_row *row in options)
		[texts addObject:[NSString stringWithFormat:@"%@ %@",
			[row type_string], row.data]];

	[self select_option:texts title:_(SHEET_SEND_SMS)
		perform:^(int selected_button) {
			BIInteractive_row *row = [options get:selected_button];
			LASSERT(row, @"Bad action sheet index?");
			[self start_facetime:row];
		}];
}

/// Saves the record in a specific address book source.
- (void)save_record_in_source:(BIAddressbook_source*)source
{
	BLOCK_UI();
	const BOOL success = [self.item save_record:source];

	UIView *view = [[UILabel round_text:success ? _(CONTACTS_SUCCESS) :
		_(CONTACTS_FAILURE) bounds:CGRectMake(0, 0, 200, 200)
		fit:YES radius:20] retain];
	[view center_inside:self.view];
	[view align_rect];

	[self.view addSubview:view];
	[UIView animateWithDuration:_FADE_OUT_SPEED delay:0
		_DEFAULT_ANIM_OPTIONS animations:^{ view.alpha = 0; }
		completion:^(BOOL finished){
			[view removeFromSuperview];
			[view release];
		}];
}

/** Lets the user pick one of the sources for the contact to save to.
 * This is a simple selector wrapper over save_record_in_source:.
 */
- (void)select_source_for_record:(NSArray*)sources
{
	BLOCK_UI();
	RASSERT(sources.count > 0, @"Too few sources to select from!", return);
	DLOG(@"Showing selection between addressbooks %@", sources);

	NSMutableArray *options = [sources get_holder];
	for (BIAddressbook_source *source in sources)
		[options addObject:NON_NIL_STRING(source.name)];

	[self select_option:options
		title:_(ABS_SELECT_TITLE) perform:^(int selected_button) {
			[self save_record_in_source:[sources get:selected_button]];
		}];
}

/** Tries to save the current item to the addressbook.
 * The method first queries the number of addressbooks, and if there are more
 * than one, shows first a list of options to select from.
 */
- (void)save_record
{
	UIView *view = [[UILabel round_text:_(CONTACTS_SAVING)
		bounds:CGRectMake(0, 0, 200, 200) fit:YES radius:20
		view:[UIActivity get_white_large]] retain];
	[view center_inside:self.view];
	[view align_rect];
	[self.view addSubview:view];

	[self after:0 perform:^{
			// We don't want the user playing with the app in the meantime.
			BLOCK_UI();
			NSArray *potential = [BIAddressbook_source get_sources];
			if (potential.count > 1) {
				[self select_source_for_record:potential];
			} else {
				[self save_record_in_source:[potential get:0]];
			}

			[view removeFromSuperview];
			[view release];
		}];
}

#pragma mark BIButton_delegate

- (void)button_cell_touched:(int)number
{
	switch (number) {
		case _BUTTON_SMS: [self prepare_sms]; break;
		case _BUTTON_FACETIME: [self prepare_facetime]; break;
		case _BUTTON_SAVE: [self save_record]; break;
		case _BUTTON_EMAIL: [self send_email:nil]; break;
		default: LASSERT(NO, @"Unknown cell button touched"); break;
	}
}

#pragma mark UITableViewDelegate

/** Fills the specified cell with the information for a given index path.
 * Returns YES if the cell was filled or NO if the indexPath didn't point to a
 * valid pair cell.
 */
- (BOOL)fill_pair_cell:(BIPair_cell*)cell path:(NSIndexPath*)indexPath
{
	if (_TAB_ROWS_JOB == indexPath.section) {
		if (0 == indexPath.row) {
			cell.left = _(CONTACTS_JOB_POSITION);
			cell.right = [self.item.job_titles get:0];
		} else {
			cell.left = _(CONTACTS_ORGANIZATION);
			cell.right = [self.item.works_for get:0];
		}
		return YES;
	} else if (_TAB_ROWS_ADDRESS == indexPath.section) {
		cell.left = _(CONTACTS_ADDRESS);
		cell.right = [self.item full_address];
		return YES;
	} else if (_TAB_ROWS_PHONES == indexPath.section) {
		BIInteractive_row *row = [self.items get:indexPath.row];
		cell.left = [row type_string];
		cell.right = row.data;
		return YES;
	} else {
		return NO;
	}
}

- (CGFloat)tab_data:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (_TAB_ROWS_ACTIONS == indexPath.section) {
		return [BIButton_cell height];
	} else {
		static BIPair_cell *test_cell = nil;
		if (!test_cell)
			test_cell = [BIPair_cell new];

		if (![self fill_pair_cell:test_cell path:indexPath]) {
			DLOG(@"Couldn't fill pair cell for %@?", indexPath);
			return 0;
		} else {
			return [BIPair_cell height_for_item:test_cell.left
				right:test_cell.right width:300];
		}
	}
}

/** Builds the cell for the table.
 */
- (UITableViewCell*)tab_data:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	LASSERT(_TAB_DATA == header_.selected_tab, @"Bad forwarding!");
	NSString *identifier = [NSString
		stringWithFormat:@"BIEntity_view_controller_data_%d_%d",
		self.item.type, indexPath.section];

	Class cell_class = [BIPair_cell class];
	if (_TAB_ROWS_ACTIONS == indexPath.section)
		cell_class = [BIButton_cell class];

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
		cell = [[[cell_class alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];

	if ([self fill_pair_cell:(id)cell path:indexPath]) {
		// Don't do anything, the method fills the cell really.
	} else if (_TAB_ROWS_ACTIONS == indexPath.section) {
		LASSERT([cell isKindOfClass:[BIButton_cell class]], @"Types!");
		BIButton_cell *b = (BIButton_cell*)cell;
		b.delegate = self;
		if (indexPath.row < 1 && (show_sms_button_ || show_facetime_button_)) {
			[b set_button:show_sms_button_ ? _(CONTACTS_BUTTON_SMS) : nil
				number:_BUTTON_SMS is_left:YES];
			[b set_button:show_facetime_button_ ? _(FACETIME) :nil
				number:_BUTTON_FACETIME is_left:NO];
		} else {
			LASSERT(1 >= indexPath.row, @"Too many rows!");
			[b set_button:_(CONTACTS_BUTTON_SHARE) number:_BUTTON_EMAIL
				is_left:YES];
			[b set_button:_(CONTACTS_BUTTON_SAVE) number:_BUTTON_SAVE
				is_left:NO];
		}
	} else {
		LASSERT(NO, @"Unexpected section for _TAB_DATA");
	}

	return cell;
}

/** Returns the number of rows in a section.
 * The number varies depending on the configuration of the item.
 */
- (NSInteger)tab_data:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
	LASSERT(_TAB_DATA == header_.selected_tab, @"Bad forwarding!");
	switch (section) {
		case _TAB_ROWS_JOB:
			return (self.item.works_for.count > 0) ? 2 : 0;

		case _TAB_ROWS_ADDRESS:
			if ([self.item full_address].length > 1 ||
					self.item.latitude || self.item.longitude)
				return 1;
			else
				return 0;

		case _TAB_ROWS_PHONES: return self.items.count;
		case _TAB_ROWS_ACTIONS:
			if (show_sms_button_ || show_facetime_button_)
				return 2;
			else
				return 1;

		default: LASSERT(NO, @"Bad section for data"); break;
	}

	return 0;
}

/** Number of sections in the table.
 * Always constant, except when there is no item.
 */
- (NSInteger)tab_data_number_of_sections
{
	LASSERT(_TAB_DATA == header_.selected_tab, @"Bad forwarding!");
	return self.item ? 4 : 0;
}

/** The user selected a row, push a controller if appropriate.
 */
- (void)tab_data:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	switch (indexPath.section) {
		case _TAB_ROWS_JOB:
			if (self.works_for_relationship) {
				BIEntity_view_controller *c = [BIEntity_view_controller new];
				[c set_api:API_ENTITY num:self.works_for_relationship.id_];
				DLOG(@"Autolinking %@", self.works_for_relationship);
				if (c) {
					// Try to find out the full name from the first row.
					BIInteractive_row *row =
						[self.works_for_relationship.rows get:0];
					if (IR_NAME == row.type)
						c.item_title = row.data;
					[self.navigationController pushViewController:c
						animated:YES];
					[c release];
				}
			}
			break;

		case _TAB_ROWS_ADDRESS:
			if (self.item.latitude || self.item.longitude) {
				BIMap_view_controller *map = [BIMap_view_controller new];
				BIAnnotation *place = [BIAnnotation new];
				place.title = [self.item full_name];
				place.coordinate = (CLLocationCoordinate2D){
					self.item.latitude, self.item.longitude };
				map.place = place;
				[place release];
				[self.navigationController pushViewController:map animated:YES];
				[map release];
			}
			break;

		case _TAB_ROWS_PHONES: {
			BIInteractive_row *row = [self.items get:indexPath.row];
			switch (row.type) {
				case IR_EMAIL: [self send_email:row.data]; break;
				case IR_PHONE: [self prepare_phone:row.data]; break;
				case IR_WEB: [self prepare_web:row.data]; break;
				case IR_TWITTER: [self prepare_web:row.data]; break;
				case IR_FACEBOOK: [self prepare_web:row.data]; break;
				case IR_LINKEDIN: [self prepare_web:row.data]; break;
				default:
					break;
			}
			break;
		}

		default:
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#ifndef _INCLUDE_DATA
@end
#endif

// vim:tabstop=4 shiftwidth=4 syntax=objc
