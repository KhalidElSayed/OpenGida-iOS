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

/** View controllers wantin to save their state need to implement this.
 */
@protocol BISerialization_protocol <NSObject>

/** Returns a three element tuple array with the status info.
 * The first element of the tuple is required to be a string, which is the full
 * string used to show in the controller header. The second and third elements
 * are NSNumber objects with the contents of the API's category and number
 * respectively.
 *
 * If your class doesn't support this or there is an error, return nil.
 */
- (NSArray*)get_serialization_tuple;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
