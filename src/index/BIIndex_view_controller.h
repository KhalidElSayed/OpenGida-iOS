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

#import "global/BIContent_table_view_controller.h"

#import "global/BIGPS.h"
#import "net/BIAPI_entry.h"
#import "protocol/BISerialization_protocol.h"

@class BIAPI_entry;
@class BIGPS;
@class BITitle_header;

/** Table view showing items to pick from.
 *
 * This class is used to navigate the hierarchy of the JSON information. It
 * supports paging if necessary.
 */
@interface BIIndex_view_controller : BIContent_table_view_controller
	<BIItem_receiver_protocol, UISearchBarDelegate, BISerialization_protocol,
	BIGPS_delegate>
{
	/// Object controlling API requests.
	BIAPI_entry *api_;

	/// View for the lock icon, when the user is too fast.
	UIView *lock_;

	/// Navigation BICategory_item objects. May be nil.
	NSArray *navigation_;

	/// Special title header.
	BITitle_header *header_;

	/// By default hidden view containing the search options.
	UIView *search_options_;

	/// Points to the location switch.
	UISwitch *location_switch_;

	/// Points to the help text near the location switch.
	UILabel *location_label_;

	/// The basic text string over the switch.
	UILabel *switch_label_;

	/// Pointer to the search bar, allows us to change the placeholder text.
	UISearchBar *search_bar_;

	/// Modified version of self.qi_titles for the table view.
	NSArray *cached_index_titles_;

	/// Pointer to the global GPS aware singleton class. Not retained.
	BIGPS *gps_;

	/// State variable used for search_bar_ scroll hidding trick.
	BOOL cancel_bounce_;
}

@property (nonatomic, retain) NSArray *navigation;

- (void)loadView_title;
- (void)loadView_search;
- (void)add_to_table_header:(UIView*)view;
- (void)set_api:(API_TYPE)type num:(int)num;
- (void)force_api_refresh;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
