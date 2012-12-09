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

@class BIEntity_item;
@class BIPerson_item;

/** View controllers need to implement this to get data from the net.
 */
@protocol BIItem_receiver_protocol <NSObject>

@optional

/** Used to pass the initial list of category items and complete navigation.
 * Keep the pointer to the items array, it may be update further by the
 * update_range: method. This method is required to be implemented for
 * API_CATEGORY request types. Other request types may implement this in order
 * to receive error message cells.
 *
 * You will also be passed, if available, two arrays which joined together
 * allow you to create the index of sections. The first array contains the
 * strings and the second one the indices to the items array.
 */
- (void)update_items:(NSArray*)items navigation:(NSArray*)navigation
	qi_titles:(NSArray*)qi_titles qi_numbers:(NSArray*)qi_numbers;

/** Tells the receiver a certain range in the category items array was changed.
 * The array consists of indexPathForRow elements for the section specified
 * with get_item_section, or zero if not available. This method is optional to
 * be implemented for API_CATEGORY request types.
 */
- (void)update_range:(NSArray*)indices;

/** Complementary method to update_range:. Specifies which section should the
 * NSIndexPath objects of update_range: be created with. This method is
 * optional to be implemented for API_CATEGORY request types.
 */
- (int)get_item_section;

/** Implemented by classes expecting entity updates.
 * Passes the new updated value of the entity. Tis method is required to be
 * implemented for API_ENTITY request types.
 */
- (void)update_entity:(BIEntity_item*)entity;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
