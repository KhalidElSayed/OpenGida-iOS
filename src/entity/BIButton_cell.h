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

#import "ELHASO_cell.h"

/** Receiving delegate required to detect button touches on the cells.
 */
@protocol BIButton_delegate <NSObject>

/** Passes the button number that was passed in set_button.
 */
- (void)button_cell_touched:(int)number;

@end


/** Handles a cell for the index views.
 */
@interface BIButton_cell : ELHASO_cell
{
	UIButton *b1_, *b2_;
	id<BIButton_delegate> delegate_;
}

@property (nonatomic, assign) id<BIButton_delegate> delegate;

+ (CGFloat)height;
- (void)set_button:(NSString*)title number:(int)number is_left:(BOOL)is_left;

@end
