package gltCommon;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(GL_PI gltDegToRad);

use constant GL_PI =>  3.1415926535897932384626433832795;

sub gltDegToRad {
    return (shift)*(GL_PI/180);
}


1;