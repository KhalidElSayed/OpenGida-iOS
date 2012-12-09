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

#import "entity/BIButton_cell.h"

#import "categories/UIColor+Bidrasil.h"

#import "ELHASO.h"


#define _PADDING				10
#define _ROW_SIZE				46


@implementation BIButton_cell

@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier
{
	if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
		return nil;

	// Prepare the stretched button images.
	UIImage *b_normal = [UIImage imageNamed:@"green_button_normal.png"];
	b_normal = [b_normal
		stretchableImageWithLeftCapWidth:b_normal.size.width / 2.0f
		topCapHeight:0];

	UIImage *b_pressed = [UIImage imageNamed:@"green_button_pressed.png"];
	b_pressed = [b_pressed
		stretchableImageWithLeftCapWidth:b_pressed.size.width / 2.0f
		topCapHeight:0];

	UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:14];

	self.selectionStyle = UITableViewCellSelectionStyleNone;
	b1_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	b1_.autoresizingMask = UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleRightMargin;
	CGRect rect = self.contentView.bounds;
	rect.origin.x = _PADDING;
	rect.size.width = (rect.size.width / 2.0f) - (3 * _PADDING / 2.0f);
	rect.size.height = _ROW_SIZE - _PADDING;
	b1_.frame = rect;
	b1_.hidden = YES;
	b1_.titleLabel.font = font;
	b1_.titleLabel.shadowColor = [UIColor title_header_text];
	b1_.titleLabel.shadowOffset = CGSizeMake(0, 1);
	b1_.titleLabel.numberOfLines = 1;
	b1_.titleLabel.adjustsFontSizeToFitWidth = YES;
	b1_.titleLabel.minimumFontSize = 10;
	[b1_ setBackgroundImage:b_normal forState:UIControlStateNormal];
	[b1_ setBackgroundImage:b_pressed forState:UIControlStateHighlighted];
	[b1_ addTarget:self action:@selector(button_touched:)
		forControlEvents:UIControlEventTouchUpInside];
	[content_view_ addSubview:b1_];

	b2_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	b2_.autoresizingMask = UIViewAutoresizingFlexibleWidth |
		UIViewAutoresizingFlexibleLeftMargin;
	rect.origin.x += rect.size.width + _PADDING;
	b2_.frame = rect;
	b2_.hidden = YES;
	b2_.titleLabel.font = font;
	b2_.titleLabel.shadowColor = [UIColor title_header_text];
	b2_.titleLabel.shadowOffset = CGSizeMake(0, 1);
	b2_.titleLabel.numberOfLines = 1;
	b2_.titleLabel.adjustsFontSizeToFitWidth = YES;
	b2_.titleLabel.minimumFontSize = 10;
	[b2_ setBackgroundImage:b_normal forState:UIControlStateNormal];
	[b2_ setBackgroundImage:b_pressed forState:UIControlStateHighlighted];
	[b2_ addTarget:self action:@selector(button_touched:)
		forControlEvents:UIControlEventTouchUpInside];
	[content_view_ addSubview:b2_];

	return self;
}

- (void)dealloc
{
	[b1_ release];
	[b2_ release];
	[super dealloc];
}

/** Returns the height for a cell.
 * This returns a constant, all buttons are equal size and made to fit.
 */
+ (CGFloat)height
{
	return _ROW_SIZE;
}

/** Simply overdraw the default rounded look, we will put our own buttons.
 */
- (void)draw_content:(CGRect)cell_rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor groupTableViewBackgroundColor] set];
	CGContextFillRect(context, cell_rect);
}

/** Sets the active button to something valid.
 * Pass the title of the button, the number you want to associate it with, and
 * whether you are setting the left or the right one. Until you call this,
 * buttons will be hidden.
 *
 * If you want to hide the button, pass an empty string or nil as title.
 */
- (void)set_button:(NSString*)title number:(int)number is_left:(BOOL)is_left
{
	UIButton *b = is_left ? b1_ : b2_;

	b.hidden = title.length < 1;
	[b setTitle:title forState:UIControlStateNormal];
	b.tag = number;

	[self setNeedsDisplay];
}

/** If the delegate exists, tell it to handle the button touch action.
 */
- (void)button_touched:(UIButton*)sender
{
	[delegate_ button_cell_touched:sender.tag];
}

@end
