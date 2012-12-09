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

#import "index/BIIndex_cell.h"

#import "global/BIGlobal.h"
#import "model/BICategory_item.h"

#import "ELHASO.h"


#define _PADDING				2
#define _ICON_SIZE				30
#define _DISCLOSURE_WIDTH		9
#define _DISCLOSURE_OFFSET		(9 + _PADDING + SCROLLBAR_WIDTH)
#define _INDENT					(_ICON_SIZE)


@implementation BIIndex_cell

- (void)dealloc
{
	[super dealloc];
}

/** Retuns the font of the cell.
 */
+ (UIFont*)get_font
{
	return [UIFont fontWithName:@"Arial" size:15];
}

/** Returns the height for a cell.
 * This is a reduced version of the draw method to figure out the height.
 */
+ (CGFloat)height_for_item:(BICategory_item*)item width:(float)width
{
	CGFloat height = _PADDING * 2;

	const CGSize max_width = CGSizeMake(width -
		_ICON_SIZE - _PADDING * 3 - _DISCLOSURE_OFFSET -
		(item.indent ? _ICON_SIZE : 0), 1000);
	NSString *text = NON_NIL_STRING(item.name);
	const CGSize size = [text
		sizeWithFont:[self get_font] constrainedToSize:max_width];
	height += size.height;
	return MAX(MINIMUM_ROW_HEIGHT, height);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = self.frame;
	const CGFloat width = rect.size.width;
	const CGFloat height = [BIIndex_cell height_for_item:self.item width:width];
	rect.size.height = height;
	self.frame = rect;
	rect = content_view_.frame;
	rect.size.width = width;
	rect.size.height = height;
	content_view_.frame = rect;
}

/** Special method that draws the custom cell content.
 */
- (void)draw_content:(CGRect)cell_rect
{
	CGRect rect = cell_rect;
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Drawn normal color if not in a special state.
	if (!(self.selected || self.highlighted)) {
		[[UIColor whiteColor] set];
		CGContextFillRect(context, cell_rect);
		static UIImage *gradient = nil;
		if (!gradient)
			gradient = [[UIImage imageNamed:@"cell_index_gradient.png"] retain];
		rect.origin.y = rect.size.height - gradient.size.height;
		rect.size.height = gradient.size.height;
		[gradient drawInRect:rect];
	}

	// Prepare normal cell size, excluding padding, disclosure and icon.
	rect = cell_rect;
	rect.origin.x = _PADDING * 2 + _ICON_SIZE +
		(self.item.indent ? _ICON_SIZE : 0);
	rect.origin.y = _PADDING;
	rect.size.width = cell_rect.size.width -
		rect.origin.x - _DISCLOSURE_OFFSET;
	rect.size.height = cell_rect.size.height - _PADDING * 2;

	UIFont *font = [BIIndex_cell get_font];
	NSString *text = _(CELL_LOADING);
	if (self.item)
		text = NON_NIL_STRING(self.item.name);
	// Calculate the text height, we may need to center it vertically.
	const CGSize size = [text sizeWithFont:font constrainedToSize:rect.size];

	LASSERT(size.height <= rect.size.height, @"Bad cell size calculations");
	rect.origin.y += MAX(0, rect.size.height - size.height) / 2;
	rect.size.height = size.height;

	[[UIColor blackColor] set];
	[text drawInRect:rect withFont:[BIIndex_cell get_font]
		lineBreakMode:UILineBreakModeTailTruncation];

	UIImage *icon = [self.item get_icon];
	if (icon) {
		rect.size = icon.size;
		rect.origin.x = floorf(_PADDING + (self.item.indent ? _ICON_SIZE : 0) +
			MAX(0, (_ICON_SIZE - rect.size.width) / 2.0f));
		rect.origin.y = floorf(cell_rect.size.height / 2.0f -
			rect.size.height / 2.0f);
		[icon drawInRect:rect];
	}
}

@end
