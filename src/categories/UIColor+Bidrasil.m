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

#import "categories/UIColor+Bidrasil.h"

@implementation UIColor (Bidrasil)

+ (UIColor*)pattern:(NSString*)filename
{
	UIImage *pattern = [UIImage imageNamed:filename];
	NSAssert(pattern, @"Couldn't load image for color pattern!");
	return [UIColor colorWithPatternImage:pattern];
}

#define _BUILD_COL(NAME,RED,GREEN,BLUE,ALPHA) \
	+ (UIColor*)NAME { return [UIColor colorWithRed:RED/255.0f \
		green:GREEN/255.0f blue:BLUE/255.0f alpha:ALPHA/255.0f]; }

_BUILD_COL(navigation_bar_green_1, 167, 225, 89, 255);
_BUILD_COL(navigation_bar_green_2, 120, 177, 44, 255);
_BUILD_COL(navigation_bar_split, 97, 142, 37, 255);
_BUILD_COL(help_cell_text, 50, 122, 39, 255);
_BUILD_COL(title_header_text, 72, 102, 30, 255);
_BUILD_COL(tab_normal_text, 157, 158, 160, 255);
_BUILD_COL(tab_normal_background, 87, 91, 92, 255);

#undef _BUILD_COL

@end
