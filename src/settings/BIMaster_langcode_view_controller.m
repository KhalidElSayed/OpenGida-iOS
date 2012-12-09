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

#import "settings/BIMaster_langcode_view_controller.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSNotificationCenter+ELHASO.h"


@implementation BIMaster_langcode_view_controller

- (void)update_texts
{
	self.intro_text = _(SETTINGS_SELECT_LANG);
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

	[BIGlobal set_data_langcode:3 == pos ? @"eu" : @"es"];
	DLOG(@"Setting data to %@", [BIGlobal get_data_langcode]);
	[BIGlobal set_ui_langcode:langcode];
	DLOG(@"Setting ui to %@", [BIGlobal get_ui_langcode]);
	[self update_texts];
	[self.tableView reloadData];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
