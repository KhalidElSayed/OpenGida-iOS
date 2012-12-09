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
#ifndef _INCLUDE_RELATED
@implementation BIEntity_view_controller
#endif


#define _RELATED_NAME			0
#define _RELATED_TYPE			1
#define _RELATED_ID				2
#define _RELATED_ROWS			3


#pragma mark UITableViewDelegate

/** Returns the number of generated interactive rows in update_local_items.
 * This method doesn't modify the class, so it can be called at any time. It
 * will only look at self.item.relationships.
 */
- (int)tab_related_rows_count
{
	int total = 0;

	// Flatten into valid an array of tuples (title, type, id, rows).
	for (BIRelationship *relationship in self.item.relationships)
		total += relationship.items.count;

	return total;
}

/** See update_local_items.
 * If you update this algorithm, remember to update also tab_related_rows_count.
 */
- (void)update_local_items_related
{
	NSMutableArray *valid = [NSMutableArray
		arrayWithCapacity:self.item.relationships.count];

	// Flatten into valid an array of tuples (title, type, id, rows).
	for (BIRelationship *relationship in self.item.relationships) {
		NSString *title = relationship.name;
		NSNumber *type = [NSNumber numberWithInt:relationship.type];
		for (BIRelationship_item *item in relationship.items) {
			NSNumber *identifier = [NSNumber numberWithInt:item.id_];
			[valid addObject:[NSArray arrayWithObjects:title,
				type, identifier, item.rows, nil]];
			title = @"";
		}
	}

	self.items = valid.count ? [NSArray arrayWithArray:valid] : nil;
}

/** Gets the texts for the specified indexPath.
 * The method fills in text1 and text2 pointers. Special cells have filled in
 * the text2 part with the interaction type label.
 */
- (void)tab_related_get_texts:(NSIndexPath*)indexPath
	text1:(NSString**)text1 text2:(NSString**)text2
{
	*text1 = *text2 = nil;
	NSArray *subarray = [self.items get:indexPath.section];
	RASSERT([subarray isKindOfClass:[NSArray class]], @"No subarray?", return);
	NSArray *rows = [subarray get:_RELATED_ROWS];
	BIInteractive_row *row = [rows get:indexPath.row];
	*text1 = row.data;

	switch (row.type) {
		case IR_ADDRESS:
		case IR_PHONE:
		case IR_FAX:
		case IR_EMAIL:
		case IR_WEB:
		case IR_TWITTER:
		case IR_FACEBOOK:
		case IR_LINKEDIN:
			*text2 = [row type_string];
			break;
		default:
			break;
	}
}

- (CGFloat)tab_related:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *text1, *text2;
	[self tab_related_get_texts:indexPath text1:&text1 text2:&text2];
	return [BISubtitle_cell height_for_item:text1 subtitle:text2];
}

/** Returns the correct cell.
 */
- (UITableViewCell*)tab_related:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	LASSERT(_TAB_RELATED == header_.selected_tab, @"Bad forwarding!");
	NSString *text1, *text2;
	[self tab_related_get_texts:indexPath text1:&text1 text2:&text2];

	NSString *identifier = text2.length ?
		@"BIEntity_view_controller_related_2" :
		@"BIEntity_view_controller_related_1";

	Class cell_class = text2.length ? [BIPair_cell class] :
		[BISubtitle_cell class];

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
		cell = [[[cell_class alloc] initWithStyle:0
			reuseIdentifier:identifier] autorelease];

	if (text2.length) {
		cell.detailTextLabel.text = text1;
		cell.textLabel.text = text2;
	} else {
		cell.textLabel.text = text1;
		cell.detailTextLabel.text = text2;
	}
	return cell;
}

/** Returns the number of rows in a section.
 * The number varies depending on the configuration of the item.
 */
- (NSInteger)tab_related:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
	LASSERT(_TAB_RELATED == header_.selected_tab, @"Bad forwarding!");
	NSArray *subarray = [self.items get:section];
	RASSERT([subarray isKindOfClass:[NSArray class]], @"No subarray?",
		return 0);
	NSArray *rows = [subarray get:_RELATED_ROWS];
	return rows.count;
}

/** Number of sections in the table.
 * Depends on the amount of relationship groups.
 */
- (NSInteger)tab_related_number_of_sections
{
	LASSERT(_TAB_RELATED == header_.selected_tab, @"Bad forwarding!");
	return self.items.count;
}

/** Returns the name of the relationship.
 */
- (NSString *)tab_related:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	NSArray *subarray = [self.items get:section];
	RASSERT([subarray isKindOfClass:[NSArray class]], @"No subarray?",
		return nil);
	NSString *title = [subarray get:_RELATED_NAME];
	return title.length ? title : nil;
}

/** The user selected a row, push a controller if appropriate.
 */
- (void)tab_related:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSArray *tuple = [self.items get:indexPath.section];
	RASSERT([tuple isKindOfClass:[NSArray class]], @"No subarray?", return);
	const API_TYPE type = [[tuple get:_RELATED_TYPE] intValue];
	const int num = [[tuple get:_RELATED_ID] intValue];
	NSArray *rows = [tuple get:_RELATED_ROWS];
	RASSERT([rows isKindOfClass:[NSArray class]], @"No rows?", return);
	BIInteractive_row *row = [rows get:indexPath.row];

	// Does the cell allow direct interaction?
	switch (row.type) {
		case IR_EMAIL: [self send_email:row.data]; break;
		case IR_PHONE: [self prepare_phone:row.data]; break;
		case IR_WEB: [self prepare_web:row.data]; break;
		case IR_FACEBOOK: [self prepare_web:row.data]; break;
		case IR_LINKEDIN: [self prepare_web:row.data]; break;
		default: {
			// No interaction, just push the controller for the linked item.
			// Well, still there's a chance that an address might have location.
			UIViewController *controller = nil;
			if (IR_ADDRESS == row.type && (row.latitude || row.longitude)) {
				BIMap_view_controller *map = [BIMap_view_controller new];
				controller = map;
				BIAnnotation *place = [BIAnnotation new];
				place.coordinate =
					(CLLocationCoordinate2D){ row.latitude, row.longitude };
				row = [rows get:0];
				if (IR_NAME == row.type)
					place.title = row.data;
				map.place = place;
				[place release];
			} else {
				BIEntity_view_controller *c = [BIEntity_view_controller new];
				controller = c;
				[c set_api:type num:num];
				// Try to find out the full name from the first row.
				row = [rows get:0];
				if (IR_NAME == row.type)
					c.item_title = row.data;
			}

			if (controller) {
				[self.navigationController pushViewController:controller
					animated:YES];
				[controller release];
			}
			break;
		}
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#ifndef _INCLUDE_RELATED
@end
#endif

// vim:tabstop=4 shiftwidth=4 syntax=objc
