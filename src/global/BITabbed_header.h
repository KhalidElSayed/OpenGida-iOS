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

#import "global/BITitle_header.h"

@protocol BITabbed_header_delegate <NSObject>
/** The user touched a tab, passing a number.
 * You are meant to handle the touch, for instance by changing your table
 * content. When you are done, return YES to tell the BITabbed_header it should
 * make the touched tab the selected one, NO if you want to reject the tab
 * change.
 */
- (BOOL)header_tab_touched:(int)number;
@end

/** Resizeable table header view with tabs.
 * Extending the BITitle_header, this view grows a 20px height row of
 * tabs/buttons you can create.
 */
@interface BITabbed_header : BITitle_header
{
	/// Array holding the buttons.
	NSMutableArray *buttons_;
	/// The same, but holding the visual areas for the buttons.
	NSMutableArray *areas_;

	/// Pointer to the parent delegate.
	id <BITabbed_header_delegate> delegate_;
}

@property (nonatomic, assign) id <BITabbed_header_delegate> delegate;
@property (nonatomic, assign) int selected_tab;

- (void)set_tabs:(NSArray*)strings;
- (void)show_tab:(BOOL)doit num:(int)pos animated:(BOOL)animated;
- (void)resize_to_width:(CGFloat)new_width animated:(BOOL)animated;

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
