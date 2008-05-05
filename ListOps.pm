package Template::Plugin::ListOps;
# Copyright (c) 2007-2008 Sullivan Beck. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

###############################################################################

$VERSION = "1.02";

require 5.004;

use warnings;
use strict;
use base qw( Template::Plugin );
use Sort::DataTypes;

=pod

=head1 NAME

Template::Plugin::ListOps - Plugin interface to list operations

=head1 SYNOPSIS

   [% USE ListOps %]

=head1 DESCRIPTION

The ListOps plugin attempts to provide a complete set of list
operations for use within templates. Initially, I intended this to be
a wrapper around the Set::Array module, so much of it's functionality
and the naming of the functions come from that. However, the
Set::Array module fails due to a weakness in the Want module, so I
ended up not using that module at all.

I realize that many of these methods already exist partially as list
virtual methods, but this is an attempt to have all of the common (or
not so common) list operations in one place. Also, these also have a
much more complete handling of duplicate list elements than those in
the virtual methods.

=head1 METHODS

Template::Plugin::ListOps makes the following methods available:

=cut

###############################################################################
###############################################################################
=pod

=over 4

=item unique

   [% list = ListOps.unique(list) %]

This removes any duplicates in a list and returns a list containing only
unique elements.

=cut

sub unique {
   shift;
   my $list = shift;

   my %ele;
   my @ret;
   foreach my $ele (@$list) {
      push(@ret,$ele), $ele{$ele} = 1  if (! exists $ele{$ele});
   }
   return [ @ret ];
}

###############################################################################
=pod

=item compact

   [% list = ListOps.compact(list) %]

This removes any undefs from a list and returns a list containing only
defined elements.

=cut

sub compact {
   shift;
   my $list = shift;

   my @ret;
   foreach my $ele (@$list) {
      push(@ret,$ele)  if (defined $ele);
   }
   return [ @ret ];
}

###############################################################################
=pod

=item union

   [% list = ListOps.union(list1,list2) %]
   [% list = ListOps.union(list1,list2,op) %]

This takes two lists and combines them depending on what "op" is.  If
op is not given, it defaults to "unique".

If op is "unique", the two lists are combined, but all duplicates are
removed.

If op is "duplicates", the lists are strictly added to each other and
all duplicates are preserved.

=cut

sub union {
   shift;
   my $list1 = shift;
   my $list2 = shift;
   my $op    = shift;
   $op       = "unique"  if (! $op);

   my @ret = (@$list1,@$list2);
   @ret = @{ unique("",\@ret) }  if ($op eq "unique");
   return [ @ret ];
}

###############################################################################
=pod

=item difference

   [% list = ListOps.difference(list1,list2) %]
   [% list = ListOps.difference(list1,list2,op) %]

This takes two lists and removes the second list from the first. The
exact method of this happending depending on what op is.  If op is
not given, it defaults to "unique".

If op is "unique", every occurence of each of it's elements is removed
from the first list.

    difference([a a b c],[a],"unique") => (b c)

If op is "duplicates", duplicates are allowed, and the first
occurence of each element in the second list is removed from the first
list.

    difference([a a b c],[a],"duplicates")  => (a b c)

=cut

sub difference {
   shift;
   my $list1 = shift;
   my $list2 = shift;
   my $op    = shift;
   $op       = "unique"  if (! $op);

   my %list2;
   foreach my $ele (@$list2) {
      $list2{$ele}++;
   }

   my @ret;
   foreach my $ele (@$list1) {
      if ($op eq "unique") {
         push(@ret,$ele)  if (! exists $list2{$ele});
      } else {
         if (exists $list2{$ele}  &&  $list2{$ele} > 0) {
            $list2{$ele}--;
         } else {
            push(@ret,$ele);
         }
      }
   }
   return [ @ret ];
}

###############################################################################
=pod

=item intersection

   [% list = ListOps.intersection(list1,list2) %]
   [% list = ListOps.intersection(list1,list2,op) %]

This takes two lists and finds the intersection of the two. The
intersection are elements that are in both lists. The manner of
treating duplicates depends on the value of op. If op is not
given, it defaults to "unique".

If op is "unique", a single instance is returned for each value in
both lists.

    intersection([a a b c],[a a a b],"unique") => (a b)

If op is "duplicates", a single instance is returned for each instance of
a value that appears in both lists.

    intersection([a a b c],[a a a b],"duplicates") => (a a b)

=cut

sub intersection {
   shift;
   my $list1 = shift;
   my $list2 = shift;
   my $op    = shift;
   $op       = "unique"  if (! $op);

   my %list2;
   foreach my $ele (@$list2) {
      $list2{$ele}++;
   }

   my @ret;
   foreach my $ele (@$list1) {
      next  if (! defined $ele);
      if (exists $list2{$ele}  &&  $list2{$ele} > 0) {
         $list2{$ele}--;
         push(@ret,$ele);
      }
   }
   @ret = @{ unique("",\@ret) }  if ($op eq "unique");
   return [ @ret ];
}

###############################################################################
=pod

=item symmetric_difference

   [% list = ListOps.symmetric_difference(list1,list2) %]
   [% list = ListOps.symmetric_difference(list1,list2,op) %]

This takes two lists and finds the symmetric difference of the
two. The symmetric difference are elements that are in either list,
but not both. The manner of treating duplicates depends on the value
of op. If op is not given, it defaults to "unique".

If op is "unique", any instance of a value negates all values in
the other list.

    symmetric_difference([a a b c],[a a a b],"unique") => (c)

If op is "duplicates", a single instance of a value only negates a
single value in the other list.

    symmetric_difference([a a b c],[a a a b],"duplicates") => (a c)

=cut

sub symmetric_difference {
   shift;
   my $list1 = shift;
   my $list2 = shift;
   my $op    = shift;
   $op       = "unique"  if (! $op);

   my %list1;
   foreach my $ele (@$list1) {
      $list1{$ele}++;
   }
   my %list2;
   foreach my $ele (@$list2) {
      $list2{$ele}++;
   }

   my @ret;
   if ($op eq "unique") {
      foreach my $ele (@$list1) {
         push(@ret,$ele)  unless (exists $list2{$ele});
      }
      foreach my $ele (@$list2) {
         push(@ret,$ele)  unless (exists $list1{$ele});
      }
      @ret = @{ unique("",\@ret) };
   } else {
      foreach my $ele (keys %list1) {
         if (exists $list2{$ele}) {
            my $min = _min($list1{$ele},$list2{$ele});
            $list1{$ele} -= $min;
            $list2{$ele} -= $min;
         }
      }
      foreach my $ele (@$list2) {
         if (exists $list1{$ele}) {
            my $min = _min($list1{$ele},$list2{$ele});
            $list1{$ele} -= $min;
            $list2{$ele} -= $min;
         }
      }
      foreach my $ele (@$list1) {
         push(@ret,$ele), $list1{$ele}--  if ($list1{$ele}>0);
      }
      foreach my $ele (@$list2) {
         push(@ret,$ele), $list2{$ele}--  if ($list2{$ele}>0);
      }
   }
   return [ @ret ];
}
sub _min {
   my($a,$b) = @_;
   return $a  if ($a<$b);
   return $b;
}

###############################################################################
=pod

=item at

   [% ele = ListOps.at(list,pos) %]

This returns the elements at the specified position. Positions are
numbered starting at 0.

=cut

sub at {
   shift;
   my $list = shift;
   my $pos  = shift;
   return $$list[$pos];
}

###############################################################################
=pod

=item sorted

   [% list = ListOps.sorted(list) %]
   [% list = ListOps.sorted(list,method [,arg,arg,...]) %]

This returns the elements of the list sorted based on a method. Sorting
is done using the methods defined in the Sort::DataTypes module, refer
to that manual for a list of methods, and the description of the
method. For example, to use the sort_domain method, use the call:

   [% list = ListOps.sorted(list,'domain') %]

All methods are available.

The following methods are available for backwards compatibility:

   forward   : same as alphabetic
   reverse   : same as rev_alphabetic
   forw_num  : same as numerical
   rev_num   : same as rev_numerical
   dates     : same as date
   rev_dates : same as rev_date

If method is not given, it defaults to alphabetic.

=cut

sub sorted {
   my(@args) = @_;
   shift @args;
   my $list = shift @args;
   my $meth = shift @args;

   $meth    = "alphabetic"  if (! $meth);

   my %meth = qw(forward       alphabetic
                 reverse       rev_alphabetic
                 forw_num      numerical
                 rev_num       rev_numerical
                 dates         date
                 rev_dates     rev_date);
   if (exists $meth{$meth}) {
      $meth=$meth{$meth};
   }

   sort_by_method($meth,$list,@args);

   my @list = @$list;
   return [ @list ];
}

###############################################################################
=pod

=item join

   [% out = ListOps.join(list,string) %]

This returns the elements joined into a string using the given string
as a separator.

=cut

sub join {
   shift;
   my $list = shift;
   my $str  = shift;
   return join($str,@$list);
}

###############################################################################
=pod

=item first, last

   [% ele = ListOps.first(list) %]
   [% ele = ListOps.last(list) %]

These return the first or last elements of the list.

=cut

sub first {
   shift;
   my $list = shift;
   return $$list[0];
}
sub last {
   shift;
   my $list = shift;
   return $$list[$#$list];
}

###############################################################################
=pod

=item shiftval, popval

   [% ele = ListOps.shiftval(list) %]
   [% ele = ListOps.popval(list) %]

These remove the first or last elements of the list and return it.

=cut

sub shiftval {
   shift;
   my $list = shift;
   return shift(@$list);
}
sub popval {
   shift;
   my $list = shift;
   return pop(@$list);
}

###############################################################################
=pod

=item unshiftval, pushval

   [% list = ListOps.unshiftval(list,vals) %]
   [% list = ListOps.pushval(list,vals) %]

These add the vals (which can be a single value or a list of values) to
either the start or end of the list.

=cut

sub unshiftval {
   shift;
   my $list = shift;
   my @vals;
   if ($#_ == 0) {
      my $vals = shift;
      if (ref($vals)) {
         @vals = @$vals;
      } else {
         @vals = ($vals);
      }
   } else {
      @vals = @_;
   }
   my @list = @$list;
   unshift(@list,@vals);
   return [ @list ];
}
sub pushval {
   shift;
   my $list = shift;
   my @vals;
   if ($#_ == 0) {
      my $vals = shift;
      if (ref($vals)) {
         @vals = @$vals;
      } else {
         @vals = ($vals);
      }
   } else {
      @vals = @_;
   }
   my @list = @$list;
   push(@list,@vals);
   return [ @list ];
}

###############################################################################
=pod

=item minval, maxval, minalph, maxalph

   [% ele = ListOps.minval(list) %]
   [% ele = ListOps.maxval(list) %]
   [% ele = ListOps.minalph(list) %]
   [% ele = ListOps.maxalph(list) %]

These return the minimum or maximum numerical value in list or
the first and last values in an alphabetically sorted list.

=cut

sub minval {
   shift;
   my $list = shift;
   my $ret  = $$list[0];
   foreach my $val (@$list) {
      $ret = $val  if ($val < $ret);
   }
   return $ret;
}
sub maxval {
   shift;
   my $list = shift;
   my $ret  = $$list[0];
   foreach my $val (@$list) {
      $ret = $val  if ($val > $ret);
   }
   return $ret;
}

sub minalph {
   shift;
   my $list = shift;
   my $ret  = $$list[0];
   foreach my $val (@$list) {
      $ret = $val  if ($val lt $ret);
   }
   return $ret;
}
sub maxalph {
   shift;
   my $list = shift;
   my $ret  = $$list[0];
   foreach my $val (@$list) {
      $ret = $val  if ($val gt $ret);
   }
   return $ret;
}

###############################################################################
=pod

=item impose

   [% list = ListOps.impose(list,string,placement) %]

This appends or prepends a string to every element in the list. placement
can be "append" or "prepend" (if it is absent, it defaults to "append").

=cut

sub impose {
   shift;
   my $list      = shift;
   my $string    = shift;
   my $placement = shift;
   $placement = "append"  if (! $placement);

   my @ret;
   if ($placement eq "append") {
      foreach my $ele (@$list) {
         push(@ret,"$ele$string");
      }
   } else {
      foreach my $ele (@$list) {
         push(@ret,"$string$ele");
      }
   }
   return [ @ret ];
}

###############################################################################
=pod

=item reverse

   [% list = ListOps.reverse(list) %]

This reverses the list.

=cut

sub reverse {
   shift;
   my $list = shift;
   return [ reverse @$list ];
}

###############################################################################
=pod

=item rotate

   [% list = ListOps.rotate(list,direction,num) %]

This rotates the list. Each rotation depends on the value of direction
which can be ftol or ltof. If it is ftol (the default direction), the
first element is removed from the list and added to the end. If it is
ltof, the last element is removed and moved to the front of the list.

This will happen num number of times (which defaults to 1).

=cut

sub rotate {
   shift;
   my $list      = shift;
   my $direction = shift;
   my $num       = shift;
   if (! $direction  ||  ($direction ne "ftol"  &&  $direction ne "ltof")) {
      $num       = $direction;
      $direction = "ftol";
   }
   $num          = 1  if (! $num);

   my @list      = @$list;
   if ($direction eq "ftol") {
      for (my $i=0; $i<$num; $i++) {
         push(@list,shift(@list));
      }
   } else {
      for (my $i=0; $i<$num; $i++) {
         unshift(@list,pop(@list));
      }
   }

   return [ @list ];
}

###############################################################################
=pod

=item count

   [% num = ListOps.count(list,val) %]

This counts the number of times val appears in the list.

=cut

sub count {
   shift;
   my $list = shift;
   my $val  = shift;

   my $num = 0;
   foreach my $ele (@$list) {
      $num++  if ($ele eq $val);
   }
   return $num;
}

###############################################################################
=pod

=item delete

   [% list = ListOps.delete(list,val) %]
   [% list = ListOps.delete(list,val,op) %]

This deletes occurences of val from the list.

If op is not given, it defaults to "unique".

If op is "unique", every occurence of val is removed from the list.

If op is "duplicates", duplicates are allowed and only the first
occurence of val is removed from the list.

=cut

sub delete {
   shift;
   my $list = shift;
   my $val  = shift;
   my $op   = shift;
   $op      = "unique"  if (! $op);

   my @ret;
   my $add  = 0;
   foreach my $ele (@$list) {
      if ($ele ne $val  ||  $add == 1) {
         push(@ret,$ele);
         next;
      }
      $add = 1  if ($op eq "duplicates");
   }
   return [ @ret ];
}

###############################################################################
=pod

=item is_equal, not_equal

   [% flag = ListOps.is_equal(list1,list2) %]
   [% flag = ListOps.is_equal(list1,list2,op) %]

   [% flag = ListOps.not_equal(list1,list2) %]
   [% flag = ListOps.not_equal(list1,list2,op) %]

This takes two lists and tests to see if they are equal or not. The
order of the elements is ignored, so (a,b) = (b,a).

If op is not given, it defaults to "unique".

If "op" is "unique", duplicates are ignored, so (a,a,b) = (a,b).

If "op" is "duplicates", the lists are strictly evaluated, and all
duplicates are kept.

=cut

sub is_equal {
   shift;
   my $list1 = shift;
   my $list2 = shift;
   my $op    = shift;
   $op       = "unique"  if (! $op);

   my %list1;
   foreach my $ele (@$list1) {
      $list1{$ele}++;
   }

   my %list2;
   foreach my $ele (@$list2) {
      $list2{$ele}++;
   }

   if ($op eq "unique") {
      foreach my $ele (@$list1) {
         return 0  if (! exists $list2{$ele});
      }
      foreach my $ele (@$list2) {
         return 0  if (! exists $list1{$ele});
      }
      return 1;
   }

   foreach my $ele (@$list1) {
      return 0  if (! exists $list2{$ele}  ||  $list2{$ele} == 0);
      $list2{$ele}--;
   }
   foreach my $ele (@$list2) {
      return 0  if (! exists $list1{$ele}  ||  $list1{$ele} == 0);
      $list1{$ele}--;
   }
   return 1;
}

sub not_equal {
   return 1 - is_equal(@_);
}

###############################################################################
=pod

=item clear

   [% list = ListOps.clear(list) %]

This returns an empty list.

=cut

sub clear {
   shift;
   my $list = shift;
   return [ ];
}

###############################################################################
=pod

=item fill

   [% list = ListOps.fill(list,val,start,length) %]

This sets elements of a list to be val.

If val is not passed in, it defaults to "". If start is not passed in,
it defaults to 0. If length is not passed in, it default to the end of
the list. If length refers past the end of the list, new values are
added to the end of the list.

=cut

sub fill {
   shift;
   my $list   = shift;
   my $val    = shift;
   my $start  = shift;
   my $length = shift;
   my @list   = @$list;
   $val       = ""  if (! defined $val);
   $start     = 0   if (! $start);
   $length    = ($#list + 1 - $start)  if (! defined $length);
   my $end    = $start + $length - 1;

   foreach my $i ($start..$end) {
      $list[$i] = $val;
   }
   return [ @list ];
}

###############################################################################
=pod

=item splice

   [% list = ListOps.splice(list,start,length,vals) %]

This performs the perl splice command on a list.

=cut

sub splice {
   shift;
   my $list   = shift;
   my $start  = shift;
   my $length = shift;
   my @vals   = @_;
   my @list   = @$list;
   if ($#vals == 0  &&  ref($vals[0]) eq "ARRAY") {
      @vals   = @{ $vals[0] };
   }
   $start     = 0   if (! $start);
   $length    = ($#list + 1 - $start)  if (! defined $length);

   splice(@list,$start,$length,@vals);
   return [ @list ];
}

###############################################################################
=pod

=item indexval, rindexval

   [% num = ListOps.indexval(list,val) %]
   [% num = ListOps.rindexval(list,val) %]

This returns the index of the first/last occurence of val in the list
(or undef if the value doesn't occur).

=cut

sub indexval {
   shift;
   my $list = shift;
   my $val  = shift;

   for (my $i=0; $i<=$#$list; $i++) {
      return $i  if ($$list[$i] eq $val);
   }
   return undef;
}
sub rindexval {
   shift;
   my $list = shift;
   my $val  = shift;

   for (my $i=$#$list; $i>=0; $i--) {
      return $i  if ($$list[$i] eq $val);
   }
   return undef;
}

###############################################################################
=pod

=item set

   [% list = ListOps.set(list,index,val) %]

This sets a specific index to a value.

=cut

sub set {
   shift;
   my $list  = shift;
   my $index = shift;
   my $val   = shift;
   my @list  = @$list;

   $list[$index] = $val;
   return [ @list ];
}

###############################################################################
###############################################################################
=pod

=back

=head1 KNOWN PROBLEMS

None at this point.

=head1 LICENSE

This script is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Sullivan Beck (sbeck@cpan.org)

=cut

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 3
# cperl-continued-statement-offset: 2
# cperl-continued-brace-offset: 0
# cperl-brace-offset: 0
# cperl-brace-imaginary-offset: 0
# cperl-label-offset: -2
# End:
