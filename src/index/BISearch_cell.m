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

#import "index/BISearch_cell.h"

#import "global/BIGlobal.h"
#import "model/BICategory_item.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"
#import "CLLocation+ELHASO.h"

#import <CoreLocation/CLLocation.h>


#define _PADDING				2
#define _ICON_SIZE				30
#define _DISCLOSURE_WIDTH		9
#define _DISCLOSURE_OFFSET		(9 + _PADDING + SCROLLBAR_WIDTH)
#define _INDENT					(_ICON_SIZE)


@implementation BISearch_cell

@synthesize user_location = user_location_;

- (void)dealloc
{
	[user_location_ release];
	[super dealloc];
}

/** Retuns the main bold font of the cell.
 */
+ (UIFont*)get_main_bold_font
{
	return [UIFont fontWithName:@"Helvetica-Bold" size:15];
}

/** Retuns the main normal font of the cell.
 */
+ (UIFont*)get_main_normal_font
{
	return [UIFont fontWithName:@"Helvetica" size:15];
}

/** Retuns the sub font of the cell.
 */
+ (UIFont*)get_sub_font
{
	return [UIFont fontWithName:@"Helvetica" size:14];
}

/** Retuns the distance font of the cell.
 */
+ (UIFont*)get_distance_font
{
	return [UIFont fontWithName:@"Arial" size:12];
}

/** Returns the distance text from a position, if available.
 * May return nil if there is no distance stored in the object. Note that while
 * the interface is for BICategory_item we are really expecting to read the
 * properties of a BISearch_item object.
 */
+ (NSString*)get_distance_text:(BICategory_item*)item from:(CLLocation*)from
{
	CLLocation *location = ASK_GETTER(item, location, nil);
	if (!location)
		return nil;

	const double dist = [from distance_to:location do_round:YES];

	if (dist < 1050) {
		return _F(CELL_DISTANCE_METERS, dist);
	} else if (dist < 10000) {
		return _F(CELL_DISTANCE_KM1, dist * 0.001);
	} else {
		return _F(CELL_DISTANCE_KM2, dist * 0.001);
	}
}

/** Splits the text lines of the name in the first line, and other lines.
 * The other_lines may end up being nil. first_line may point to the empty
 * string, but never nil.
 */
+ (void)split_item_lines:(BICategory_item*)item
	first_line:(NSString**)first_line other_lines:(NSString**)other_lines
{
	*first_line = *other_lines = nil;

	NSArray *lines = ASK_GETTER(item, lines,
		[item.name componentsSeparatedByString:@"\n"]);

	*first_line = NON_NIL_STRING([lines get:0]);
	if (lines.count > 1)
		*other_lines = [[lines subarrayWithRange:(NSRange){1, lines.count - 1}]
			componentsJoinedByString:@"\n"];
}

/** Returns the height for a cell.
 * This is a reduced version of the draw method to figure out the height.  Pass
 * in show_distance if the cell should show the distance text. It should only
 * be shown if the user location is available.
 */
+ (CGFloat)height_for_item:(BICategory_item*)item width:(float)width
	show_distance:(BOOL)show_distance
{
	CGFloat height = _PADDING * 2;

	const CGSize max_width = CGSizeMake(width -
		_ICON_SIZE - _PADDING * 2 - _DISCLOSURE_OFFSET, 1000);

	NSString *first_line, *other_lines;
	[BISearch_cell split_item_lines:item
		first_line:&first_line other_lines:&other_lines];
	CGSize size = [first_line
		sizeWithFont:[self get_main_bold_font] constrainedToSize:max_width];
	height += size.height;

	if (other_lines.length) {
		size = [other_lines
			sizeWithFont:[self get_sub_font] constrainedToSize:max_width];
		height += size.height;
	}

	if (show_distance) {
		// Use a default location from Bilbao to make the text size calculation.
		static CLLocation *from = 0;
		if (!from)
			from = [[CLLocation alloc] initWithLatitude:43.242202
				longitude:-2.945023];

		NSString *text = [BISearch_cell get_distance_text:item from:from];
		if (text) {
			size = [text sizeWithFont:[self get_distance_font]
				constrainedToSize:max_width];
			height += size.height;
		}
	}

	return MAX(MINIMUM_ROW_HEIGHT, height);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = self.frame;
	const CGFloat width = rect.size.width;
	const CGFloat height = [BISearch_cell height_for_item:self.item
		width:width show_distance:self.user_location != nil];
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
	rect.origin.x = _PADDING * 2 + _ICON_SIZE;
	rect.origin.y = _PADDING;
	rect.size.width = cell_rect.size.width -
		rect.origin.x - _DISCLOSURE_OFFSET;
	rect.size.height = cell_rect.size.height - _PADDING * 2;

	// Substract the distance text height.
	CGFloat distance_height = 0;
	NSString *text = nil;
	if (self.user_location && (text = [BISearch_cell
			get_distance_text:self.item from:self.user_location])) {

		const CGSize max_width = CGSizeMake(rect.size.width -
			_ICON_SIZE - _PADDING * 2 - _DISCLOSURE_OFFSET, 1000);
		distance_height = [text sizeWithFont:[BISearch_cell get_distance_font]
			constrainedToSize:max_width].height;
	}
	rect.size.height -= distance_height;

	NSString *first_line, *other_lines;
	[BISearch_cell split_item_lines:self.item
		first_line:&first_line other_lines:&other_lines];
	[[UIColor blackColor] set];

	if (other_lines.length) {
		/// Draw multiple lines, some smaller than the rest.
		CGSize size = [first_line drawInRect:rect
			withFont:[BISearch_cell get_main_bold_font]
			lineBreakMode:UILineBreakModeTailTruncation];
		rect.origin.y += size.height;
		rect.size.height -= size.height;

		[[UIColor grayColor] set];
		size = [other_lines drawInRect:rect
			withFont:[BISearch_cell get_sub_font]
			lineBreakMode:UILineBreakModeTailTruncation];
		rect.origin.y += size.height;
		rect.size.height -= size.height;
	} else {
		// Single line, calculate if we need to center it vertically.
		text = self.item ? NON_NIL_STRING(self.item.name) : _(CELL_LOADING);
		CGSize size = [text sizeWithFont:[BISearch_cell get_main_normal_font]
			constrainedToSize:rect.size];

		LASSERT(size.height <= rect.size.height, @"Bad cell size calculations");
		rect.origin.y += MAX(0, rect.size.height - size.height) / 2;
		rect.size.height = size.height;

		size = [text drawInRect:rect
			withFont:[BISearch_cell get_main_normal_font]
			lineBreakMode:UILineBreakModeTailTruncation];
		rect.origin.y += size.height;
		rect.size.height -= size.height;
	}

	// Draw the distance text if available.
	if (distance_height > 0) {
		text = [BISearch_cell get_distance_text:self.item
			from:self.user_location];
		[[UIColor darkGrayColor] set];
		[text drawInRect:rect withFont:[BISearch_cell get_distance_font]
			lineBreakMode:UILineBreakModeTailTruncation
			alignment:UITextAlignmentRight];
	}

	UIImage *icon = [self.item get_icon];
	if (icon) {
		rect.size = icon.size;
		rect.origin.x = floorf(_PADDING +
			MAX(0, (_ICON_SIZE - rect.size.width) / 2.0f));
		rect.origin.y = floorf(cell_rect.size.height / 2.0f -
			rect.size.height / 2.0f);
		[icon drawInRect:rect];
	}

#if 0
	// Don't draw disclosures for error cells.
	if (API_ERROR == self.item.type)
		return;

	// Draw the disclosure, centered vertically.
	UIImage *disclosure = [UIImage imageNamed:@"default_disclosure.png"];
	LASSERT(disclosure, @"Couldn't load disclosure");
	rect.size = disclosure.size;
	rect.origin.x = cell_rect.size.width - _DISCLOSURE_OFFSET;
	rect.origin.y = floorf(cell_rect.size.height / 2.0f -
		rect.size.height / 2.0f);
	[disclosure drawInRect:rect];
#endif
}

@end
