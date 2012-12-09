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

#import "settings/BISelector_view_controller.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"


@implementation BISelector_view_controller

@synthesize intro_text = intro_text_;
@synthesize selected_row = selected_row_;

- (UITableViewStyle)table_style
{
	return UITableViewStyleGrouped;
}

- (void)loadView
{
	[super loadView];
	[self.tableView reloadData];
}

- (void)dealloc
{
	[super dealloc];
}

/** Called when the user touches one of the rows in the table.
 * This is a dummy method. Subclasses are meant to override it to get the
 * selected row and do something, possibly change user settings and stuff.
 * Stuff, nice word!
 *
 * Note that this method is called regardless of the previous selection, it may
 * be called several times in a row (by the clueless user).
 */
- (void)row_touched:(int)pos
{
	DLOG(@"BISelector_view_controller row_touched:%d", pos);
}

#pragma mark -
#pragma mark UITableViewDelegate

/** Returns the correct cell.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *identifier = @"BISelector_view_controller_cell";

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
		cell = [[[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];

	cell.textLabel.text = [self.items get:indexPath.row];
	cell.accessoryType = (self.selected_row == indexPath.row) ?
		UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (NSInteger)tableView:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
	return self.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

/** Returns the name of a section.
 * This is only used by the related tab to group relationships.
 */
- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	return self.intro_text;
}

/** User interacted with a row, change selection.
 */
- (void)tableView:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = nil;

	// Do we need to reset the mark of the previous selection cell?
	if (self.selected_row != indexPath.row) {
		cell = [tableView cellForRowAtIndexPath:[NSIndexPath
			indexPathForRow:self.selected_row inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	// Update selection and force a check on the appropriate cell.
	self.selected_row = indexPath.row;
	cell = [tableView cellForRowAtIndexPath:[NSIndexPath
		indexPathForRow:self.selected_row inSection:0]];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[self row_touched:indexPath.row];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
