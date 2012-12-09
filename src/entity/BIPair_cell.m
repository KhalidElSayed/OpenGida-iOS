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

#import "entity/BIPair_cell.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"


@implementation BIPair_cell

- (id)init
{
	return [self initWithStyle:UITableViewCellStyleValue2
		reuseIdentifier:@"BIPair_cell"];
}

- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleValue2
		reuseIdentifier:reuseIdentifier];
	self.textLabel.adjustsFontSizeToFitWidth = YES;
	self.textLabel.minimumFontSize = 8;
	self.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
	self.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:15];
	self.detailTextLabel.numberOfLines = 0;

	return self;
}


- (void)setLeft:(NSString*)left
{
	self.textLabel.text = left;
	run_on_ui(^{ [self setNeedsDisplay]; });
}

- (NSString*)left
{
	return self.textLabel.text;
}

- (void)setRight:(NSString*)right
{
	self.detailTextLabel.text = right;
	run_on_ui(^{ [self setNeedsDisplay]; });
}

- (NSString*)right
{
	return self.detailTextLabel.text;
}

/** Returns the height for a cell.
 * Terrible terrible hack, this only works because the width is hardcoded to
 * 215 pixels, but really, the default size methods are really awkward.
 */
+ (CGFloat)height_for_item:(NSString*)left right:(NSString*)right
	width:(float)width
{
	static BIPair_cell *tester = nil;
	if (!tester)
		tester = [BIPair_cell new];

	tester.left = left;
	tester.right = right;
	[tester layoutSubviews];

	CGSize size = [tester.detailTextLabel sizeThatFits:CGSizeMake(207, 1000)];
	const CGFloat padding = 6;
	const CGFloat total = MAX(MINIMUM_ROW_HEIGHT, padding * 2 + size.height);
	//DLOG(@"Returning %0.1f for %@", total, right);
	return total;
}

@end
