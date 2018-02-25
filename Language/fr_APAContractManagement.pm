# --
# Kernel/Language/APA_ContractManagement.pm - core module
# Copyright (C) (2016) (Aurelien PAGES) (apages2@free.fr)
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

package Kernel::Language::fr_APAContractManagement;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;


    $Self->{Translation}->{'Overview'} = 'Aperçu';
	$Self->{Translation}->{'MEP Management'} = 'Gestion des MEP';
	$Self->{Translation}->{'MEP Area.'} = 'Zone MEP';
	$Self->{Translation}->{'MEP Information Center'} = 'Tableau de Bord MEP';
	$Self->{Translation}->{'MEP Admin'} = 'Administration MEP';
	$Self->{Translation}->{'SAGE Customers'} = 'Clients SAGE';
	$Self->{Translation}->{'OTRS Customers'} = 'Clients OTRS';
	$Self->{Translation}->{'Duration'} = 'Durée';
	$Self->{Translation}->{'Start Date'} = 'Date de Démarrage';
	$Self->{Translation}->{'Starting Date ='} = 'Date de Démarrage =';
	$Self->{Translation}->{'Starting Date >='} = 'Date de Démarrage >=';
	$Self->{Translation}->{'Starting Date <='} = 'Date de Démarrage <=';
	$Self->{Translation}->{'Entry Date ='} = 'Date de Saisie =';
	$Self->{Translation}->{'Entry Date >='} = 'Date de Saisie >=';
	$Self->{Translation}->{'Entry Date <='} = 'Date de Saisie <=';
	$Self->{Translation}->{'End Date'} = 'Date de Fin';
	$Self->{Translation}->{'Entry Date'} = 'Date de Saisie';
	$Self->{Translation}->{'Wildcards like \'*\' are allowed. Date Format is YYYY-MM-DD'} = 'Les jokers comme \'*\' sont autorisés. Le format des dates est YYYY-MM-DD';
	$Self->{Translation}->{'Search'} = 'Rechercher';
	$Self->{Translation}->{'Show next pages'} = 'Afficher pages suivantes';
	$Self->{Translation}->{'Show last page'} = 'Afficher la dernière page';
	$Self->{Translation}->{'Show page %s'} = 'Afficher la page %s';
	$Self->{Translation}->{'Show or hide the content'} = 'Afficher ou masquer le contenu';
		
		
	#AdminContractManagement
	$Self->{Translation}->{'Admin MEP Management'} = 'Admin Gestion des MEP';
	$Self->{Translation}->{'Manage the definitions for MEP Management.'} = 'Gérer le suivi des MEP.';
	$Self->{Translation}->{'Yes'} = 'Oui';
	$Self->{Translation}->{'No'} = 'Non';
	$Self->{Translation}->{'Entitled'} = 'Intitulé';
	$Self->{Translation}->{'Business Code'} = 'Code Affaire';
	$Self->{Translation}->{'Transfer to MSC'} = 'Transfert au MSC';
	$Self->{Translation}->{'Renew'} = 'Renouvellement';
	$Self->{Translation}->{'List'} = 'Liste';
	$Self->{Translation}->{' Search in all Cases'}  = ' Rechercher dans toutes les affaires';
	$Self->{Translation}->{' Search in all contracts'}  = ' Rechercher dans tous les contrats';
	$Self->{Translation}->{' Search in expired contracts'}  = ' Rechercher dans les contrats expirés';
	$Self->{Translation}->{'items'}  = 'éléments';
	$Self->{Translation}->{'Date in Otrs Database'} = 'Date dans la base OTRS';
	$Self->{Translation}->{'Date in Sage Database'} = 'Date dans la base Sage';
		
	#AgentContractManagement
	$Self->{Translation}->{'MEP Task'} = 'Tache MEP';
	$Self->{Translation}->{'Responsible'} = 'Responsable';
	$Self->{Translation}->{'Progress'} = 'Avancement';
	$Self->{Translation}->{'Del'} = 'Supp';
	$Self->{Translation}->{'Add'} = 'Ajout';
	$Self->{Translation}->{'Never notified'} = 'Jamais notifié';
	$Self->{Translation}->{'Notified on'} = 'Notifié le';
	$Self->{Translation}->{'Notified'} = 'Notifié';
	$Self->{Translation}->{'time(s)'} = 'fois';
	$Self->{Translation}->{'Affaire Code'} = 'Code Affaire';
	$Self->{Translation}->{'Contract Type'} = 'Type de Contrat';
	$Self->{Translation}->{'Perimeter'} = 'Perimetre';
	$Self->{Translation}->{'Reporting'} = 'Rapport';
	$Self->{Translation}->{'Contracts Subscribed'} = 'Contrats Souscrits';
		
	#AboZoomContractManagement
	$Self->{Translation}->{'Contract'} = 'Contrat';
	$Self->{Translation}->{'Amount'} = 'Quantité';
	$Self->{Translation}->{'Unit Price HT'} = 'Prix Unitaire HT';
	$Self->{Translation}->{'Go to overview'} = 'Aller à la vue d\'ensemble';
	$Self->{Translation}->{'Total Price HT'} = 'Prix Total HT';
	$Self->{Translation}->{'Nbr of Devices'} = 'Nbr Equipements';
	$Self->{Translation}->{'Nbr of Devices /'} = 'Nbr Equipements /';
	$Self->{Translation}->{'Nbr of Indicators'} = 'Nbr Indicateurs';
	$Self->{Translation}->{'Nbr of Versions'} = 'Nbr de versions';
	$Self->{Translation}->{'Report'} = 'Rapport';
	$Self->{Translation}->{'Metrology'} = 'Metrologie';
		$Self->{Translation}->{'Nbr of days'} = 'Nbr de jours';
		
	#POOL
	$Self->{Translation}->{'UO Pool'} = 'Banque d\'UO';
	$Self->{Translation}->{'RTC Pool'} = 'Banque RTC';
	$Self->{Translation}->{'UO Pool'} = 'Banque d\'UO';
	$Self->{Translation}->{'Balance'} = 'Solde';	
	$Self->{Translation}->{'Disable'} = 'Désactiver';
	$Self->{Translation}->{'NEW SOLDE'} = 'Nouveau Solde';	
	$Self->{Translation}->{'Deadline'} = 'Echéance';
	$Self->{Translation}->{'Contract N°'} = 'N° Contrat';
	$Self->{Translation}->{'Contract Number'} = 'Numéro de Contrat';
	$Self->{Translation}->{'Selling Price'} = 'Prix de Vente';
	$Self->{Translation}->{'State Communicated'} = 'Etat communiqué';
	$Self->{Translation}->{'Customer mail'} = 'Mail Client';
	$Self->{Translation}->{'Contracted'} = 'Souscrit';
	$Self->{Translation}->{'Available'} = 'Disponible';
	$Self->{Translation}->{'Who ?'} = 'à qui ?';
	$Self->{Translation}->{'Change'} = 'MàJ';
	$Self->{Translation}->{'Add Contract'} = 'Ajouter Contrat';
	$Self->{Translation}->{'Add Deduct'} = 'Ajouter Décompte';
	$Self->{Translation}->{'Renew Contract'} = 'Renouveler Contrat';
	$Self->{Translation}->{'Deduct UO'} = 'Décompte d\'UO';
	$Self->{Translation}->{'Number of UO deduct'} = 'Nombre d\'UO décompté';
	$Self->{Translation}->{' (Recommended Deduct : '} = ' (Décompte Conseillé : ';
	$Self->{Translation}->{'Recommended <br> Deduct : '} = 'Décompte <br> Conseillé : ';
	
	};

1;
