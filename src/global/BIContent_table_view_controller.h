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

#import "global/BIContent_view_controller.h"

/** Helper code for table content controllers.
 *
 * This is based on the article by Matt Gallagher
 * (http://cocoawithlove.com/2009/03/recreating-uitableviewcontroller-to.html).
 * While this is not strictly a copy&paste, let's put his copyright
 * notice for completeness:
 *
//  BaseViewController.m
//  RecreatedTableViewController
//
//  Created by Matt Gallagher on 22/03/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
 *
 */
@interface BIContent_table_view_controller : BIContent_view_controller
	<UITableViewDelegate, UITableViewDataSource>
{
	/// Our own storage for the table view.
	UITableView *table_view_;

	/// Items to show by the controller.
	NSArray *items_;

	/// Set by the parent controller, creates a table header cell with a
	/// multiline string for the title.
	NSString *item_title_;

	/// Holds the array of section titles for the quick index.
	NSArray *qi_titles_;

	/// Holds the array of section positions for the quick index.
	NSArray *qi_numbers_;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSString *item_title;
@property (nonatomic, retain) NSArray *qi_titles;
@property (nonatomic, retain) NSArray *qi_numbers;

- (UITableViewStyle)table_style;
- (void)refresh_table_header;

@end
