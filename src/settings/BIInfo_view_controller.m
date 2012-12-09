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

#import "settings/BIInfo_view_controller.h"

#import "categories/UIColor+Bidrasil.h"
#import "categories/UINavigationBar+Bidrasil.h"
#import "global/BIGlobal.h"
#import "settings/BIHTML_view_controller.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "NSNotificationCenter+ELHASO.h"


#define _FILENAME				@"index.plist"


@implementation BIInfo_view_controller

@synthesize title = title_;

- (void)loadView
{
	[super loadView];

#if 0
	self.navigationItem.title = self.title.length ?
		self.title : _(WEBHELP_DEFAULT_TITLE);
	self.navigationItem.titleView = nil;
#else
	self.title = @"";
	self.navigationItem.title = self.title;
#endif

	if (self.items.count < 1) {
		NSString *path = [BIGlobal get_path_lang:_FILENAME];
		self.items = [NSArray arrayWithContentsOfFile:path];
	}

	[[NSNotificationCenter defaultCenter] refresh_observer:self
		selector:@selector(refresh_api:)
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
	//[UINavigationBar show_bidrasil:NO];
	[self.navigationController.navigationBar setNeedsDisplay];
}

/** Called when the user changes globally the ui language.
 * We need to refresh the table, so that cells reflect the new user selection.
 */
- (void)refresh_api:(NSNotification*)notification
{
	run_on_ui(^{
			DLOG(@"refreshing BIInfo_view_controller %@", notification);
			NSString *path = [BIGlobal get_path_lang:_FILENAME];
			self.items = [NSArray arrayWithContentsOfFile:path];
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

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
	cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"BIInfo_cell";
	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIColor help_cell_text];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 10;
	}

	cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
	cell.textLabel.text = [self.items get:indexPath.row * 2];
	return cell;
}

/** Returns the total number of items or the number of rows in a section.
 */
- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)num_section
{
	return self.items.count / 2;
}

- (void)tableView:(UITableView *)tableView
	didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Disable titles, we prefer branding.
	NSString *title = @""; //[self.items get:indexPath.row * 2];
	id content = [self.items get:indexPath.row * 2 + 1];

	if ([content isKindOfClass:[NSString class]]) {
		BIHTML_view_controller *controller = [BIHTML_view_controller new];
		controller.title = title;
		controller.filename = content;
		controller.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	} else {
		NSArray *child_items = content;
		if (child_items.count) {
			BIInfo_view_controller *controller = [BIInfo_view_controller new];
			controller.title = title;
			controller.items = child_items;
			controller.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:controller
				animated:YES];
			[controller release];
		} else {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
