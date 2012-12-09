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

#import <UIKit/UIKit.h>

/** \class UIColor
 * Appends some custom helpers to UIColor.
 */
@interface UIColor (Bidrasil)
+ (UIColor*)pattern:(NSString*)filename;
+ (UIColor*)navigation_bar_green_1;
+ (UIColor*)navigation_bar_green_2;
+ (UIColor*)navigation_bar_split;
+ (UIColor*)help_cell_text;
+ (UIColor*)title_header_text;
+ (UIColor*)tab_normal_text;
+ (UIColor*)tab_normal_background;
@end
