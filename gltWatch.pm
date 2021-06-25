package gltWatch;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltDoFPS);
use Data::Dumper;
eval 'use Time::HiRes qw( gettimeofday )';
my $hasHires = !$@;

use constant CLOCKS_PER_SEC => $hasHires ? 1000 : 1;
use constant FRAME_RATE_SAMPLES => 50;

our  $FrameCount = 0;
our $FrameRate = 0;
my  $last=0;

sub gltDoFPS {
  if (++$FrameCount >= FRAME_RATE_SAMPLES)
  {
     my $now = $hasHires ? gettimeofday() : time(); # clock();
     my $delta= ($now - $last);
     $last = $now;

     $FrameRate = FRAME_RATE_SAMPLES / ($delta || 1);
     $FrameCount = 0;
  }
}

#sub initFPS {
#    my $now = $hasHires ? gettimeofday() : time(); # clock();
#    $last = $now;
#}

1;
