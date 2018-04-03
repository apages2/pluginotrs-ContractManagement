# --
# Kernel/Language/de_CustomerCompanyImportExport.pm - provides german language
# Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# translation for CustomerCompanyImportExport module
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Anna(dot)Litvinova(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
#
# --
# $Id: de_CustomerCompanyImportExport.pm,v 1.4 2015/11/16 07:15:23 tlange Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Language::de_CustomerCompanyImportExport;

use strict;
use warnings;
use utf8;

# --
sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return if ref $Lang ne 'HASH';

    # possible charsets
    $Self->{Charset} = [ 'utf-8', ];

    # $$START$$

    # translations missing in ImportExport...
    $Lang->{'CustomerCompany'}            = 'Kunden-Firma';
    $Lang->{'Column Seperator'}           = 'Spaltentrenner';
    $Lang->{'Charset'}                    = 'Zeichensatz';
    $Lang->{'Restrict export per search'} = 'Export mittels Suche einschränken';
    $Lang->{'Object backend module registration for the import/export module.'}
        = 'Objekt-Backend Modul Registration des Import/Export Moduls.';
    $Lang->{
        'Defines which customer ID to use if no company defined - only relevant for new customer users.'
        }
        = 'Definiert welche Kunden-ID genutzt wird, falls nicht in Mapping definiert - nur fuer neue Kundennutzereintraege relevant.';

    return 0;

    # $$STOP$$
}

# --
1;
