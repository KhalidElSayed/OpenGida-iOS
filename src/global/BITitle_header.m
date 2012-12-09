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

#import "categories/UIColor+Bidrasil.h"

#import "ELHASO.h"


#define _LEFT_PADDING		10
#define _RIGHT_PADDING		25
#define _HEIGHT				62


@implementation BITitle_header

- (id)initWithFrame:(CGRect)rect
{
	const CGFloat width = rect.size.width;
	if (!(self = [super initWithFrame:rect]))
		return nil;

	self.backgroundColor = [UIColor groupTableViewBackgroundColor];
	label_ = [[UILabel alloc] initWithFrame:rect];
	label_.backgroundColor = [UIColor clearColor];
	label_.font = [UIFont systemFontOfSize:18];
	label_.lineBreakMode = UILineBreakModeMiddleTruncation;
	label_.textColor = [UIColor title_header_text];
	label_.text = @"";
	label_.numberOfLines = 0;
	label_.shadowColor = [UIColor whiteColor];
	label_.shadowOffset = CGSizeMake(0, 1.5f);
	[self addSubview:label_];

	[self resize_to_width:width];
	return self;
}

- (void)dealloc
{
	[label_ release];
	[super dealloc];
}

/** Sets the text of the title header.
 * This forces a cell resize. But note that UITableViews usually ignore these!
 * You have to call again setTableHeaderView on the parent.
 */
- (void)setText:(NSString*)text
{
	label_.text = text;
	[self resize_to_width:self.bounds.size.width];
}

/** Returns the text of the title header.
 */
- (NSString*)text
{
	return label_.text;
}

/** Special method called by the parent to resize the title with animation.
 * This is usually called from willAnimateRotationToInterfaceOrientation,
 * passing the new width of the screen.
 */
- (void)resize_to_width:(CGFloat)new_width
{
	CGRect rect = { _LEFT_PADDING, 0, new_width -
		_LEFT_PADDING - _RIGHT_PADDING, 1000 };
#if ALLOWS_LANDSCAPE
	const CGSize size = [label_ sizeThatFits:rect.size];
	rect.size = size;
	label_.frame = rect;

	rect = self.frame;
	rect.size.width = new_width;
	rect.size.height = size.height + _PADDING * 2;
	self.frame = rect;
#else
	rect.size.height = _HEIGHT + [self extra_height];
	label_.frame = rect;

	rect = self.frame;
	rect.size.width = new_width;
	rect.size.height = _HEIGHT + [self extra_height];
	self.frame = rect;
#endif
}

/// By default returns zero, used by subclasses.
- (int)extra_height
{
	return 0;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
