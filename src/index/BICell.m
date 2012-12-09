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

#import "index/BICell.h"

#import "global/BIGlobal.h"
#import "model/BICategory_item.h"

#import "ELHASO.h"

@implementation BICell

@synthesize item = item_;

- (void)dealloc
{
	[item_ release];
	[super dealloc];
}

/** Sets the item of the cell.
 * Since cells are reused, this method practically does the equivalent
 * of deallocating and reallocating memory and other data, but without
 * actually doing so.
 */
- (void)setItem:(BICategory_item*)item
{
	if (item_ == item)
		return;

	[item retain];
	[item_ release];
	item_ = item;

	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark UIAccessibility Protocol

- (NSString*)accessibilityLabel
{
	if (self.item)
		return NON_NIL_STRING(self.item.name);
	else
		return _(CELL_LOADING);
}

@end
