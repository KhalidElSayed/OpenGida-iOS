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

#import "model/BIRelationship_item.h"

#import "model/BIInteractive_row.h"
#import "model/JSON_helpers.h"

#import "ELHASO.h"
#import "NSDictionary+ELHASO.h"

@interface BIRelationship_item ()
@end

@implementation BIRelationship_item

@synthesize id_ = id__;
@synthesize rows = rows_;

/** Initializes a relationship item.
 */
- (id)init_with_data:(NSDictionary*)data;
{
	LASSERT([data isKindOfClass:[NSDictionary class]], @"Bad data type");
	if (!(self = [super init]))
		return nil;

	id__ = [data get_int:@"id" def:-1];
	if (id__ < 0) {
		DLOG(@"Can't create BIRelationship_item with invalid identifier");
		[self release];
		return nil;
	}

	self.rows = parse_json_items([data get_array:@"rows"
		of:[NSArray class] def:nil], [BIInteractive_row class]);

	if (self.rows.count < 1) {
		DLOG(@"Can't create BIRelationship_item without valid rows");
		[self release];
		return nil;
	}

	return self;
}

- (void)dealloc
{
	[rows_ release];
	[super dealloc];
}

/** Debugging helper.
 */
- (NSString*)description
{
	return [NSString stringWithFormat:@"BIRelationship_item {id:%d, %@}",
		id__, rows_];
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
