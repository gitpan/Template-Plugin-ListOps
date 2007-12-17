sub test {
  my($test,$data,$runtests) = @_;

  # What directory are we in

  $dir = ".";
  if (-f "t/$test.exp") {
     $dir = "t";
  }

  # Expected values

  $exp = new IO::File;
  $exp->open("$dir/$test.exp");
  @exp = <$exp>;
  chomp(@exp);

  # Processed values

  $t   = Template->new();
  $t->process("$dir/01.in", $data,"$dir/$test.out");
  $out = new IO::File;
  $out->open("$dir/$test.out");
  @out = <$out>;
  chomp(@out);

  # Number of tests

  $t = $#out;
  $t = $#exp  if ($#exp > $t);
  $t++;
  print "Test $test...\n";
  print "1..$t\n";

  # Check each test

  $t = 0;
  foreach $exp (@exp) {
    $t++;
    $out = shift(@out);

    if ($exp eq $out) {
       print "ok $t\n"  if (! defined $runtests or $runtests==0);
    } else {
       warn "########################\n";
       warn "Expected = $exp\n";
       warn "Got      = $out\n";
       warn "########################\n";
       print "not ok $t\n";
    }
  }

  foreach $out (@out) {
    $t++;

    warn "########################\n";
    warn "Unexpected test\n";
    warn "Got      = $out\n";
    warn "########################\n";
    print "not ok $t\n";
  }
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

