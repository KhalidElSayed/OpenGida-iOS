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

/** Table view showing a text and some selection cells with checks.
 */
@interface BISelector_view_controller : BIContent_table_view_controller
{
	NSString *intro_text_;
	int selected_row_;
}

/// Set this to a large text, explaining what the selection is for.
@property (nonatomic, retain) NSString *intro_text;
/// Set this to the index of the selected row. If you don't, first post!
@property (nonatomic, assign) int selected_row;

/// Subclass and override this method to know which option gets selected.
- (void)row_touched:(int)pos;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
