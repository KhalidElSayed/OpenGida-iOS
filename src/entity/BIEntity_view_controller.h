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

#import "entity/BIButton_cell.h"
#import "global/BITabbed_header.h"
#import "net/BIAPI_entry.h"
#import "protocol/BISerialization_protocol.h"

@class BIEntity_item;
@class BIInteractive_row;
@class BIRelationship_item;
@class BITabbed_header;

/** Dummy class, some day this will grow into a pretty entity viewer.
 */
@interface BIEntity_view_controller : BIContent_table_view_controller
	<BITabbed_header_delegate, BIItem_receiver_protocol, BIButton_delegate,
	UIActionSheetDelegate, MFMessageComposeViewControllerDelegate,
	UIAlertViewDelegate, BISerialization_protocol>
{
	/// Object controlling API requests.
	BIAPI_entry *api_;

	/// Pointer to the view that is above the table.
	BITabbed_header *header_;
	/// Stores the last tab that was visible.
	int last_tab_;

	/// Witness to prevent multiple api changes.
	BOOL did_set_api_;

	/// Pointer to a single item to be displayed.
	BIEntity_item *item_;

	struct {
		UIActionSheet *sheet_;
		void (^block_)(int selected_button);
	} action;

	void (^ask_block_)(BOOL accepted);

	/// Precalculated values to ease table cell handling.
	BOOL show_sms_button_, show_facetime_button_;
}

@property (nonatomic, retain) BIEntity_item *item;
@property (nonatomic, retain) BIRelationship_item *works_for_relationship;

- (void)set_api:(API_TYPE)type num:(int)num;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
