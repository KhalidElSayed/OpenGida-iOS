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

#import "net/BIAPI_types.h"

@class BIInteractive_row;

/** Group objects with information about entity/person relationships.
 * Each relationship groups one or more entities/people who are related in some
 * way to the holder of the BIRelationship object. Isn't that nice? The linked
 * items of a relationship are all of the same type.
 */
@interface BIRelationship : NSObject
{
	API_TYPE type_;
	NSString *name;
	NSArray *items;
}

/// Type of the items held by this BIRelationship object.
@property (nonatomic, readonly, assign) API_TYPE type;
/// Name of the BIRelationship, or rather the string that groups them together.
@property (nonatomic, retain) NSString *name;
/// The BIRelationship_item objects linked by the group.
@property (nonatomic, retain) NSArray *items;

- (id)init_with_data:(NSDictionary*)data;
- (int)total_rows;
- (BIInteractive_row*)get_flat_row:(int)position;
- (int)flat_row_id:(int)position;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
