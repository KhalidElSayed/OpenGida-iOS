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

#import "global/BITabbed_header.h"

#import "categories/UIColor+Bidrasil.h"
#import "global/BIGlobal.h"

#import "ELHASO.h"
#import "NSArray+ELHASO.h"

#import <QuartzCore/CALayer.h>


#define _HEIGHT			22
#define _SPACING		14
#define _BUTTON_EXTRA	14
#define _MIN_BUTTON		40
#define _PATTERN		7
#define _AREA_OFFSET	15


@interface BITabbed_header ()
- (void)resize_tab_widths:(CGFloat)new_width animated:(BOOL)animated;
@end


@implementation BITabbed_header

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)rect
{
	if (!(self = [super initWithFrame:rect]))
		return nil;

	label_.textColor = [UIColor whiteColor];
	self.backgroundColor = [UIColor pattern:@"tab_header_background.png"];
	label_.shadowColor = [UIColor blackColor];
	self.clipsToBounds = YES;
	return self;
}

- (void)dealloc
{
	[areas_ release];
	[buttons_ release];
	[super dealloc];
}

/** Property accesor to set the selected tab.
 * You need to have called set_tabs: before, or this won't have any effect. If
 * you pass a value out of range, all tabs will be deselected. Tabs are
 * numbered from zero to infinite.
 */
- (void)setSelected_tab:(int)num
{
	int f = 0;
	for (UIButton *button in buttons_)
		button.selected = (num == f++);
	f = 0;
	for (UIView *area in areas_)
		area.backgroundColor = (num == f++) ?
			[UIColor groupTableViewBackgroundColor] :
			[UIColor tab_normal_background];
}

/** Returns the currently selected tab, or -1 if none are selected.
 */
- (int)selected_tab
{
	int f = 0;
	for (UIButton *button in buttons_) {
		if (button.selected)
			return f;
		else
			f++;
	}
	return -1;
}

/** Special method called by the parent to resize the title with animation.
 * This is usually called from willAnimateRotationToInterfaceOrientation,
 * passing the new width of the screen. Hidden tabs won't be considered towards
 * the total size.
 */
- (void)resize_to_width:(CGFloat)new_width
{
	[super resize_to_width:new_width];
	[self resize_tab_widths:new_width animated:NO];
}

/** Special method called by the parent to resize the title with animation.
 * This is usually called from willAnimateRotationToInterfaceOrientation,
 * passing the new width of the screen. Hidden tabs won't be considered towards
 * the total size.
 */
- (void)resize_to_width:(CGFloat)new_width animated:(BOOL)animated
{
	[super resize_to_width:new_width];
	[self resize_tab_widths:new_width animated:animated];
}

/** Internal helper of resize_to_width implementing animation, only for tabs.
 */
- (void)resize_tab_widths:(CGFloat)new_width animated:(BOOL)animated
{
	CGRect total_rect = self.frame;
	total_rect.size.height += _HEIGHT;
	self.frame = total_rect;
	if (buttons_.count < 1)
		return;

#if 0
	const CGFloat total_width = total_rect.size.width;
#endif

	void (^resize_tabs)(void) = ^{
		// Filter the buttons which are enabled or not into separate arrays.
		NSMutableArray *enabled_buttons = [buttons_ get_holder];
		NSMutableArray *disabled_buttons = [buttons_ get_holder];
		for (UIButton *button in buttons_) {
			if (button.enabled)
				[enabled_buttons addObject:button];
			else
				[disabled_buttons addObject:button];
		}

		// First, calculate the wanted width of the labels.
		NSMutableArray *sizes = [enabled_buttons get_holder];
		CGFloat wanted_width = - _SPACING;
		for (UIButton *button in enabled_buttons) {
			UILabel *label = button.titleLabel;
			const CGSize size = [label.text sizeWithFont:label.font];
			// Wrap the widths to multiples of spacing.
			int w = ((size.width + _BUTTON_EXTRA + _SPACING - 1) / _PATTERN);
			w *= _PATTERN;
			[sizes addObject:[NSNumber numberWithFloat:w]];
			wanted_width += _SPACING + w;
		}

#if 0
		// Calculate the excess of size for the total of labels, may need to
		// trim it a little bit.
		int remaining_excess = (wanted_width - (total_width - 2 * _SPACING)) +
			0.5f;
		// Don't try to compensate due to the background patterns being
		// multiples of a big multiple.
		remaining_excess = 0;
		const int average_excess = (remaining_excess /
			((float)MAX(1, enabled_buttons.count - 1))) + 0.5;
		// Extra spacing happens when there's plenty of room. We just pad all
		// tabs.
		const int extra_spacing = average_excess < 0 ? -average_excess : 0;
#else
		const int extra_spacing = 0;
#endif

		// Prepare the rect for the buttons.
		CGRect rect = total_rect;
		rect.origin.y = rect.size.height - 2 * _HEIGHT;
		const CGFloat enabled_button_height = rect.origin.y;
		rect.size.height = 2 * _HEIGHT;
		rect.origin.x = _SPACING;
		// We use an inset to have the button label draw at the bottom of the
		// area. The background image is special in that it contains a
		// transparent area equal to the inset.
		const UIEdgeInsets insets = UIEdgeInsetsMake(_HEIGHT, 0, 0, 0);

		int f = 0;
		for (UIButton *button in enabled_buttons) {
			wanted_width = [[sizes get:f] floatValue];
			rect.size.width = wanted_width;

#if 0
			// Try to cut some slack from the current width, but not too much.
			if (remaining_excess > 0) {
				const int to_trim = remaining_excess /
					(float)(enabled_buttons.count - f);
				rect.size.width -= to_trim;
				if (rect.size.width >= _MIN_BUTTON) {
					remaining_excess -= to_trim;
				} else {
					rect.size.width = _MIN_BUTTON;
					remaining_excess -= wanted_width - rect.size.width;
				}
			}
#endif

			UIView *area = [areas_ get:button.tag];
			rect.origin.y += _AREA_OFFSET;
			area.frame = rect;
			rect.origin.y -= _AREA_OFFSET;

			button.frame = rect;
			button.alpha = 1;
			button.contentEdgeInsets = insets;
			// Switch to next button.
			rect.origin.x += rect.size.width + _SPACING + extra_spacing;
			f++;
		}

		// Finally, for disabled buttons simply take their position and move
		// them down visually, so they appear hidden.
		for (UIButton *button in disabled_buttons) {
			rect = button.frame;
			rect.origin.y = enabled_button_height + _HEIGHT;
			button.frame = rect;
			button.alpha = 0;

			UIView *area = [areas_ get:button.tag];
			rect.origin.y += _AREA_OFFSET;
			area.frame = rect;
		}
	};

	if (animated)
		[UIView animateWithDuration:1 delay:0 DEFAULT_ANIM_OPTIONS
			animations:^{  resize_tabs(); } completion:nil];
	else
		resize_tabs();
}

/** The user touched a top button.
 * Tell the delegate.
 */
- (void)button_touched:(UIButton*)sender
{
	if ([delegate_ header_tab_touched:sender.tag])
		self.selected_tab = sender.tag;
}

/** Changes the number of labels in the control.
 * Pass an array of strings, each of which will be assigned to a tab from left
 * to right. The position is significant for the header_tab_touched: delegate.
 * By default no tab is selected.
 *
 * The buttons created won't have their sizes correctly set. You need to call
 * resize_to_width later to position them correctly.
 */
- (void)set_tabs:(NSArray*)strings
{
	// Remove previous buttons.
	for (UIButton *button in buttons_)
		[button removeFromSuperview];
	for (UIView *area in areas_)
		[area removeFromSuperview];
	UNLOAD_OBJECT(buttons_);
	UNLOAD_OBJECT(areas_);

	if (strings.count < 1)
		return;

	LASSERT(strings.count > 0, @"We don't like zero/negative division!");

	// Create row of buttons.
	buttons_ = [[NSMutableArray arrayWithCapacity:4] retain];
	areas_ = [[NSMutableArray arrayWithCapacity:4] retain];
	int f = 0;
	for (NSString *text in strings) {
		// First add the background view which looks like a rounded tab.
		UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
		view.layer.cornerRadius = 10;
		view.layer.masksToBounds = YES;
		view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		[areas_ addObject:view];
		[self addSubview:view];
		[view release];

		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:text forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
		button.titleLabel.shadowOffset = CGSizeMake(0, 1);

		[button setTitleColor:[UIColor tab_normal_text]
			forState:UIControlStateNormal];
		[button setTitleShadowColor:[UIColor clearColor]
			forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor]
			forState:UIControlStateSelected];
		[button setTitleShadowColor:[UIColor whiteColor]
			forState:UIControlStateSelected];
		[button setTitleColor:[UIColor whiteColor]
			forState:UIControlStateHighlighted];
		[button setTitleShadowColor:[UIColor clearColor]
			forState:UIControlStateHighlighted];

		button.tag = f++;

		[button addTarget:self action:@selector(button_touched:)
			forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[buttons_ addObject:button];
	}
}

/** Sets the visible bit for a specific tab.
 * This forces a call to resize_to_width with the current width.
 */
- (void)show_tab:(BOOL)doit num:(int)pos animated:(BOOL)animated
{
	int f = 0;
	for (UIButton *button in buttons_) {
		if (pos == f++) {
			button.enabled = doit;
			[self resize_to_width:self.bounds.size.width animated:animated];
			return;
		}
	}
}

/// Ask the parent class to give us a little bit more room head.
- (int)extra_height
{
	return 20;
}

@end

// vim:tabstop=4 shiftwidth=4 syntax=objc
