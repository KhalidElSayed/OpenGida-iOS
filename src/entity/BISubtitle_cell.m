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

#import "entity/BISubtitle_cell.h"

#import "global/BIGlobal.h"

#import "ELHASO.h"


@implementation BISubtitle_cell

- (id)init
{
	return [self initWithStyle:UITableViewCellStyleSubtitle
		reuseIdentifier:@"BISubtitle_cell"];
}

- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle
		reuseIdentifier:reuseIdentifier];
	self.textLabel.numberOfLines = 0;
	self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	self.detailTextLabel.numberOfLines = 0;
	self.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:14];

	return self;
}

/** Returns the height for a cell.
 * Terrible terrible hack, this only works because the width is hardcoded to
 * 280 pixels, but really, the default size methods are really awkward.
 */
+ (CGFloat)height_for_item:(NSString*)title subtitle:(NSString*)subtitle
{
	static BISubtitle_cell *tester = nil;
	if (!tester)
		tester = [BISubtitle_cell new];

	tester.textLabel.text = title;
	tester.detailTextLabel.text = subtitle;
	[tester layoutSubviews];

	CGFloat height = 8;
	CGSize size = [title sizeWithFont:tester.textLabel.font
		constrainedToSize:CGSizeMake(280, 1000)];
	height += size.height;

	if (subtitle.length)
		size = [subtitle sizeWithFont:tester.detailTextLabel.font
			constrainedToSize:CGSizeMake(280, 1000)];
	else
		size.height = 0;

	return MAX(MINIMUM_ROW_HEIGHT, height + size.height);
}

@end
