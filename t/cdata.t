#!/usr/bin/perl
	use Test::More tests=>7;
	use strict;

	package Family;
	use base 'Class::Data::Global';

	Family->mk_cdata(father=>'Homer');
	Family->mk_many(mother=>'Marge',children=>{son=>'Bart',daughter=>'Lisa',baby=>'Maggie'});

	#tests
	package main;
	is(Family->father,"Homer","&mk_cdata");
	is(Family->children->{daughter},"Lisa","&mk_many");

	package Simpsons;
	use base 'Family';

	Simpsons->mk_cdata_global(coworkers=>[qw/Lenny Carl/]);
	Simpsons->mk_many_global(gangster=>'Tony',dog=>'Brian');
	
	#tests
	package main;
	is(Class::Data::Global->coworkers->[0],"Lenny","&mk_cdata_global");
	is(Class::Data::Global->dog,"Brian","&mk_many_global");

	package FamilyGuy;
	use base 'Family';

	FamilyGuy->setmany(father=>'Peter',mother=>'Lois',children=>{son=>'Chris',daughter=>'Meg',baby=>'Stewie'});
	my ($father,$children) = FamilyGuy->getmany(qw/father children/);

	FamilyGuy->check_or_mk_global(_father=>'Homer');

	#tests
	package main;
	is(FamilyGuy->mother,"Lois","&setmany");
	is($father,FamilyGuy->father,"&getmany");
	is(FamilyGuy->_father,"Homer","&check_or_mk_global");
