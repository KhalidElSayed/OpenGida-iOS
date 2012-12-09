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

/** Models containing basic information about a person.
 * Usually contained within an BIEntity_item. Note that since this is a
 * pointer, true separate data like first/last name is composed for brevity
 * just to show the user an overview of the person.
 */
@interface BIRelated_person : NSObject
{
	int id__;
	NSString *full_name_;
	NSString *job_;
	NSString *image_;
}

/// Identifier of the information pointed by this item.
@property (nonatomic, readonly, assign) int id_;
/// URL of the image, if available.
@property (nonatomic, retain) NSString *image;
/// Always present, specifies the full name of the person.
@property (nonatomic, retain) NSString *full_name;
/// Always present, specifies the job title of the person in the organization.
@property (nonatomic, retain) NSString *job;

- (id)init_with_data:(NSArray*)data;
- (UIViewController*)get_controller;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
