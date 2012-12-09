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

/** This file is included from BIEntity_view_controller. Don't compile it!
 */
#ifndef _INCLUDE_PEOPLE
@implementation BIEntity_view_controller
#endif


#pragma mark UITableViewDelegate

- (CGFloat)tab_people:(UITableView*)tableView
	heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	BIRelated_person *person = [self.item.people get:indexPath.row];
	return [BISubtitle_cell height_for_item:person.full_name
		subtitle:person.job];
}

/** Returns the correct cell.
 */
- (UITableViewCell*)tab_people:(UITableView*)tableView
	cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	LASSERT(_TAB_PEOPLE == header_.selected_tab, @"Bad forwarding!");
	NSString *identifier = [NSString
		stringWithFormat:@"BIEntity_view_controller_people_%d_%d",
		self.item.type, indexPath.section];

	UITableViewCell *cell = [tableView
		dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[BISubtitle_cell alloc]
			initWithStyle:0 reuseIdentifier:identifier] autorelease];
	}

	BIRelated_person *person = [self.item.people get:indexPath.row];
	cell.textLabel.text = person.full_name;
	cell.detailTextLabel.text = person.job;
	return cell;
}

/** The user selected a row, push a controller if appropriate.
 */
- (void)tab_people:(UITableView*)tableView
	didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	BIRelated_person *person = [self.item.people get:indexPath.row];
	UIViewController *controller = [person get_controller];
	if (!controller) {
		DLOG(@"Oops, no controller for %@ at %@?", person, indexPath);
		return;
	}

	[self.navigationController pushViewController:controller animated:YES];
}

#ifndef _INCLUDE_DATA
@end
#endif

// vim:tabstop=4 shiftwidth=4 syntax=objc
