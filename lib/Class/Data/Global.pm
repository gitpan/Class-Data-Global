package Class::Data::Global;
	use strict qw/vars subs/;
	use vars qw/$names $global_class $VERSION/;
	$VERSION ='0.1'; 
#functions
	#this method is a copy from Class::Data::Inheritable
	sub mk_cdata {
	    my ($declaredclass, $attribute, $data) = @_;

	    my $accessor = sub {
		my $wantclass = ref($_[0]) || $_[0];

		#could put this statement after $data = in order for parent
		#modification + then break
		#return $wantclass->mk_cdata($attribute)->(@_)
		#  if @_>1 && $wantclass ne $declaredclass;
		#commented to have a global constant data source

		$data = $_[1] if @_>1;
		return $data;
	    };

	    push(@{$names},$attribute);

	    *{$declaredclass.'::'.$attribute} = $accessor;
	    my $alias = "_${attribute}_accessor";
	    *{$declaredclass.'::'.$alias}     = $accessor;
	}
	sub mk_many {
		my ($class,%args) = @_;
		while (my ($key,$value) = each %args) {
			$class->mk_cdata($key=>$value);
		} 
	}	
	sub setmany {
		my ($class,%args) = @_;
		while (my ($k,$v) = each %args) {
			$class->$k($v) || die "can't set $k";
		} 
	}
	sub getmany {
		my $class = shift;
		my @return;
		for (@_) {
			push(@return,$class->$_);
		}
		return @return;
	} 
	sub mk_cdata_global {
		my $childclass = shift;
		__PACKAGE__->global_class->mk_cdata(@_);
	}	
	sub mk_many_global {
		my ($class,%args) = @_;
		while (my ($key,$value) = each %args) {
			$class->mk_cdata_global($key=>$value);
		} 
	}
	sub check_or_mk_global {
		my ($class,%choices) = @_;
		while (my ($k,$v) = each %choices ) {
			#($class->can($k) && $class->$k($v)) || $class->mk_cdata_global($k=>$v);
			$class->can($k) || $class->mk_cdata_global($k=>$v);
	       	}
	}
	sub set_or_mk_global {
		my ($class,%choices) = @_;
		while (my ($k,$v) = each %choices ) {
			($class->can($k) && $class->$k($v)) || $class->mk_cdata_global($k=>$v);
	       	}
	}

	#todo: method to set global class
	__PACKAGE__->mk_cdata(global_class=>__PACKAGE__);

	#not public
	sub print_names {
		#use Data::Dumper;
		#for (@{$names}) { print "$_\n"; my $temp = __PACKAGE__->$_; print Dumper $temp }
		print join(' ',@{$names}),"\n";
	}

1;

__END__	

=head1 NAME

Class::Data::Global - Handles global class data that both parent and child classes can read,write and create.

=head1 SYNOPSIS
	
	package Family;
	use base 'Class::Data::Global';

	Family->mk_cdata(father=>'Homer');
	Family->mk_many(mother=>'Marge',children=>{son=>'Bart',daughter=>'Lisa',baby=>'Maggie'});

	package Simpsons;
	use base 'Family';

	print "When the's the last time you saw ", Simpsons->father," strangle ",
	Simpsons->children->{son},"?\n";

	Simpsons->mk_cdata_global(coworkers=>[qw/Lenny Carl/]);
	Simpsons->mk_many_global(gangster=>'Tony',dog=>'Brian');

	package FamilyGuy;
	use base 'Family';

	FamilyGuy->setmany(father=>'Peter',mother=>'Lois',children=>{son=>'Chris',daughter=>'Meg',baby=>'Stewie'});
	my ($father,$children) = FamilyGuy->getmany(qw/father children/);

	print "Who's dumber, ",$children->{son}," or $father ?\n";
	print "Who's smarter, ",$children->{baby}," or ",FamilyGuy->dog,"?\n";

	FamilyGuy->check_or_mk_global(father=>'Homer');

=head1 DESCRIPTION 
	
This module creates accessors/mutators for global and local class data.
The accessors access scalar values which can hold references to any data type.
From the above example, class data coworkers and children contain references
to an array and hash respectively.

Global class data can be read,written and created by child classes as well as the parent
class. As global implies, all classes see the same value for a given
accessor.  For example, &mk_many_global makes a global data accessor for
dog which is later used in the class FamilyGuy.

Local class data can be read and written by the parent class and its children
but can't be created by the children. If you're looking for local class data
that children classes can't change then look at Class::Data::Inheritable.
An above example of local class datum is 'father' which is defined in the class Family
and later redefined in class FamilyGuy.

=head1 Class Methods

	Note: a [] around a data type in a function definition means its required

	mk_cdata([$name],$value)
		__PACKAGE__->mk_cdata(boss=>'Smithers');

		This method is the base accessor constructor. Use it for making a
		local class accessor.

	mk_many([%name_value_pair])
		__PACKAGE__->mk_many(bartender=>'Moe',silly_cop=>'Chief Wigams');

		A macro of mk_cdata to make several local class constructors in
		one call.

	mk_cdata_global([$name],$value)
		__PACKAGE__->cdata_global(nerd=>'Milhouse');	

		Method to create a global class accessor.

	mk_many_global([%name_value_pair])
		__PACKAGE__->mk_many_global(clown=>'Krusty',bully=>'Nelson');

		A macro of mk_cdata_global to create several global class accessors in
		one call.

	setmany([%name_value_pair])
		__PACKAGE__->setmany();

		A macro to set several constructors in one call.

	getmany([@names])
		my ($family,$father,$coworkers) = __PACKAGE__->(qw/family father coworkers/);

		A macro to return an array of values for given accessors.
	
	check_or_mk_global([%name_value_pair])
		__PACKAGE__->check_mk_global(bully=>'Nelson',merchant=>'Apu');

		Checks to see if the given accessor(s) exist. If they don't, then they are
		created.

=head1 TODO		

Making a method (global_class()) that sets the class in which all global class data is defined.  

=head1 AUTHOR

Me. Gabriel that is. If you want to bug me with a bug: cldwalker@chwhat.com
If you like using perl,linux,vim and databases to make your life easier (not lazier ;) check out my website
at www.chwhat.com.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl
itself.
