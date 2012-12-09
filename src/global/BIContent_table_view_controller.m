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

#import "global/BIContent_table_view_controller.h"

#import "ELHASO.h"

@interface BIContent_table_view_controller ()
@end

@implementation BIContent_table_view_controller

@synthesize tableView = table_view_;
@synthesize items = items_;
@synthesize item_title = item_title_;
@synthesize qi_titles = qi_titles_;
@synthesize qi_numbers = qi_numbers_;

/** Handles creation of the view, pseudo constructor.
 * We let the FLContent_view_controller create the views, and then
 * we sneakily replace the view with our table view, carefully
 * reattaching the original subviews.
 */
- (void)loadView
{
	LASSERT(self.nibName.length < 1, @"We dislike nibs");
	[super loadView];

	UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds
		style:[self table_style]];
	table.autoresizingMask = FLEXIBLE_SIZE;
	table.contentMode = UIViewContentModeScaleAspectFit;
	// On iOS 5 the default is UITableViewCellSeparatorStyleSingleLineEtched.
	// http://stackoverflow.com/questions/7780644/white-line-at-bottom-of-uitableview-cell-at-end-of-section-in-grouped-tableview/7805615#7805615
	table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

	[self.view addSubview:table];
	self.tableView = table;
	[table release];

	// Reparent the normal connection views.
	[connecting_label_ removeFromSuperview];
	[self.view addSubview:connecting_label_];

	if (UITableViewStyleGrouped == [self table_style])
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)unload_view
{
	/* Try to prevent race conditions for cells? See
	 * http://stackoverflow.com/questions/3740502/does-uitableviewcontroller-have-special-behavior-when-being-popped-off-a-uinaviga
	 */
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	UNLOAD_VIEW(table_view_);
}

/** Frees up all resources.
 */
- (void)dealloc
{
	wait_for_ui(^{ [self unload_view]; });
	[item_title_ release];
	[items_ release];
	[qi_titles_ release];
	[qi_numbers_ release];
	[super dealloc];
}

/** Property accesors.
 */
- (UITableView*)tableView
{
	return table_view_;
}

- (void)setTableView:(UITableView*)table_view
{
	if (table_view_ == table_view)
		return;

	[table_view_ release];
	table_view_ = [table_view retain];
	[table_view_ setDelegate:self];
	[table_view_ setDataSource:self];
}

/** Default table style. Override to provide a different one.
 */
- (UITableViewStyle)table_style
{
	return UITableViewStylePlain;
}

/** Takes the current tableHeaderView, removes it and puts it again.
 * This is usually necessary when you manually resize the table header, but
 * only changing that doesn't move the tableview accordingly. You have to force
 * a full reset of the property so that the tableView gets resized correctly.
 */
- (void)refresh_table_header
{
	UIView *view = [self.tableView.tableHeaderView retain];
	self.tableView.tableHeaderView = nil;
	self.tableView.tableHeaderView = view;
	[view release];
}

#pragma mark -
#pragma mark UITableViewDelegate

/** Comply with the prococol. This needs subclassing anyway...
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
	cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

@end
