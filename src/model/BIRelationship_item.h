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

/** Models containing basic information about a relationship entity.
 * Usually contained within an BIRelationship. Just like BIRelated_person, this
 * is a kind of pointer to the real actual item. Actually, a
 * BIRelationship_item is basically a small wrapper around an NSArray of
 * BIInteractive_row objects which compose the BIRelationship_item.
 */
@interface BIRelationship_item : NSObject
{
	int id__;
	NSArray *rows_;
}

/// Identifier of the information pointed by this item.
@property (nonatomic, readonly, assign) int id_;
/// BIInteractive_row objects for the interface. Always contains at least one.
@property (nonatomic, retain) NSArray *rows;

- (id)init_with_data:(NSDictionary*)data;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
