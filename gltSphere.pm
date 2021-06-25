package gltSphere;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltDrawSphere);
use OpenGL qw/ :all/;
use Data::Dumper;
#use constant GL_PI =>  3.1415;
use gltCommon qw/GL_PI/;
use gltVector3;
use gltMatrix;

sub gltDrawSphere {
    my ($fRadius, $iSlices, $iStacks) = @_;
    my $drho   = GL_PI/$iStacks;
    my $dtheta = 2.0 * GL_PI/ $iSlices;
    my $ds     = 1.0/$iSlices;
    my $dt     = 1.0/$iStacks;
    my $t      = 1.0;
    my $s      = 0.0;
    my ($i, $j);

    for($i = 0; $i < $iStacks; $i++) {
	my $rho     = $i * $drho;
	my $srho    = sin($rho);
	my $crho    = cos($rho);
	my $srhodrho= sin($rho+$drho);
	my $crhodrho= cos($rho+$drho);
	
        glBegin(GL_TRIANGLE_STRIP);
        $s = 0.0;
	for($j=0; $j <= $iSlices; $j++) {
	    my $theta = ($j == $iSlices)? 0.0 : $j * $dtheta;
	    my $stheta= -sin($theta);
	    my $ctheta= cos($theta);
	    my $x     = $stheta * $srho;
	    my $y     = $ctheta * $srho;
	    my $z     = $crho;
	    
	    glTexCoord2f($s, $t);
            glNormal3f($x, $y, $z);
            glVertex3f($x * $fRadius, $y * $fRadius, $z * $fRadius);

            $x = $stheta * $srhodrho;
            $y = $ctheta * $srhodrho;
            $z = $crhodrho;
            glTexCoord2f($s, $t - $dt);
            $s += $ds;
            glNormal3f($x, $y, $z);
            glVertex3f($x * $fRadius, $y * $fRadius, $z * $fRadius);
	}
	glEnd();
	$t -= $dt;
    }
}

1;
