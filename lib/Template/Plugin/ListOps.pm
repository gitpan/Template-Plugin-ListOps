package Template::Plugin::ListOps;
# Copyright (c) 2007-2008 Sullivan Beck. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

###############################################################################

$VERSION = "1.03";

require 5.004;

use warnings;
use strict;
use base qw( Template::Plugin );
use Template::Plugin;
use Sort::DataTypes;

###############################################################################
###############################################################################

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

sub at {
   shift;
   my $list = shift;
   my $pos  = shift;
   return $$list[$pos];
}

###############################################################################

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

sub join {
   shift;
   my $list = shift;
   my $str  = shift;
   return join($str,@$list);
}

###############################################################################

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

sub reverse {
   shift;
   my $list = shift;
   return [ reverse @$list ];
}

###############################################################################

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

sub clear {
   shift;
   my $list = shift;
   return [ ];
}

###############################################################################

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

sub set {
   shift;
   my $list  = shift;
   my $index = shift;
   my $val   = shift;
   my @list  = @$list;

   $list[$index] = $val;
   return [ @list ];
}

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
