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

/** Models the contact information of an entity.
 */
@interface BIContact_info : NSObject
{
	NSArray *emails_, *webs_, *phones_, *faxes_, *twitters_;
	NSArray *facebooks_, *linkedins_;
}

/// If present, contains all the emails of the entity as strings.
@property (nonatomic, retain) NSArray *emails;
/// If present, contains all the web addresses of the entity as strings.
@property (nonatomic, retain) NSArray *webs;
/// If present, contains all the phone numbers of the entity as strings.
@property (nonatomic, retain) NSArray *phones;
/// If present, contains all the fax numbers of the entity as strings.
@property (nonatomic, retain) NSArray *faxes;
/// If present, contains all the twitter handles of the entity as strings.
@property (nonatomic, retain) NSArray *twitters;
/// If present, contains all the facebook handles of the entity as strings.
@property (nonatomic, retain) NSArray *facebooks;
/// If present, contains all the linkedin handles of the entity as strings.
@property (nonatomic, retain) NSArray *linkedins;

- (id)init_with_json:(NSDictionary*)data;
- (NSArray*)interactive_rows;
- (NSArray*)facetime_rows;
- (NSArray*)sms_rows;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
