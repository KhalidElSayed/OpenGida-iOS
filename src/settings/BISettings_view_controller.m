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

#import "settings/BISettings_view_controller.h"

#import "categories/UINavigationBar+Bidrasil.h"
#import "global/BIGlobal.h"
#import "settings/BIInfo_view_controller.h"
#import "settings/BISelector_view_controller.h"

#import "ELHASO.h"
#import "NSNotificationCenter+ELHASO.h"


//////////////// Private data langcode selector class

@interface BIData_langcode_view_controller : BISelector_view_controller {}
@end

@implementation BIData_langcode_view_controller

- (id)init
{
	if (!(self = [super init]))
		return nil;

	self.intro_text = _(SETTINGS_SELECT_CONTENT);
	self.items = [NSArray arrayWithObjects:
		_(DATA_LANGCODE_ES), _(DATA_LANGCODE_EU), nil];
	if ([@"eu" isEqualToString:[BIGlobal get_data_langcode]])
		self.selected_row = 1;

	return self;
}

- (void)row_touched:(int)pos
{
	[BIGlobal set_data_langcode:pos ? @"eu" : @"es"];
	DLOG(@"Setting data to %@", [BIGlobal get_data_langcode]);
}

@end


//////////////// Private ui langcode selector class

@interface BIUI_langcode_view_controller : BISelector_view_controller {}
@end

@implementation BIUI_langcode_view_controller

- (void)update_texts
{
	self.intro_text = _(SETTINGS_SELECT_UI);
	self.items = [NSArray
		arrayWithObjects:_(UI_LANG_AUTOMATIC), @"English",
		@"Español", @"Euskara", nil];
}

- (id)init
{
	if (!(self = [super init]))
		return nil;

	[self update_texts];

	NSString *langcode = [BIGlobal get_ui_langcode];
	if ([@"eu" isEqualToString:langcode])
		self.selected_row = 3;
	else if ([@"en" isEqualToString:langcode])
		self.selected_row = 1;
	else if ([@"es" isEqualToString:langcode])
		self.selected_row = 2;
	else
		self.selected_row = 0;

	return self;
}

- (void)row_touched:(int)pos
{
	NSString *langcode = @"auto";
	switch (pos) {
		case 1: langcode = @"en"; break;
		case 2: langcode = @"es"; break;
		case 3: langcode = @"eu"; break;
		default: break;
	}
	[BIGlobal set_ui_langcode:langcode];
	DLOG(@"Setting ui to %@", [BIGlobal get_ui_langcode]);
	[self update_texts];
	[self.tableView reloadData];
}

@end


@implementation BISettings_view_controller

- (UITableViewStyle)table_style
{
	return UITableViewStyleGrouped;
}

- (void)loadView
{
	[super loadView];

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center refresh_observer:self selector:@selector(refresh_api:)
		name:BIData_langcode_did_change object:nil];

	[center refresh_observer:self selector:@selector(refresh_api:)
		name:BIUI_langcode_did_change object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[UINavigationBar show_bidrasil:YES];
	[self.navigationController.navigationBar setNeedsDisplay];
}

/** Called when the user changes globally the ui language.
 * We need to refresh the table, so that cells reflect the new user selection.
 */
- (void)refresh_api:(NSNotification*)notification
{
	run_on_ui(^{
			DLOG(@"refreshing BISettings_view_controller %@", notification);
			[self.tableView reloadData];
			[self set_ui_labels];
		});
}

#pragma mark Rotation handlers

- (BOOL)shouldAutorotateToInterfaceOrientation:
	(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark UITableViewDelegate

/** Returns the correct cell.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString *identifier = @"BISettings_view_controller_cell";

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
		cell = [[[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];

	NSString *text = @"Dummy";
	if (0 == indexPath.section) {
		text = (0 == indexPath.row) ?
			_F(SETTINGS_FORMAT_CONTENT, [BIGlobal get_data_lang_string]) :
			_F(SETTINGS_FORMAT_UI, [BIGlobal get_ui_lang_string]);
	} else {
		text = _(SETTINGS_USAGE_GUIDE);
	}

	cell.textLabel.text = text;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (NSInteger)tableView:(UITableView*)tableView
	numberOfRowsInSection:(NSInteger)section
{
	return section ? 1 : 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 2;
}

/** Returns the name of a section.
 * This is only used by the related tab to group relationships.
 */
- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	if (0 == section)
		return _(SETTINGS_SECTION_LANG);
	else
		return _(SETTINGS_SECTION_INFO);
}

/** User interacted with a row, push a new controller.
 */
- (void)tableView:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UIViewController *controller = nil;
	if (0 == indexPath.section) {
		if (0 == indexPath.row)
			controller = [BIData_langcode_view_controller new];
		else
			controller = [BIUI_langcode_view_controller new];
	} else {
		controller = [BIInfo_view_controller new];
	}
	LASSERT(controller, @"No controller?");

	if (controller) {
		controller.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
