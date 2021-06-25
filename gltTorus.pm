package gltTorus;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltDrawTorus gltToonDrawTorus);
use OpenGL qw/ :all/;
use Data::Dumper;
#use constant GL_PI =>  3.1415;
use gltCommon qw/GL_PI/;
use gltVector3;
use gltMatrix;

sub gltToonDrawTorus {
    my ($majorRadius, $minorRadius, $numMajor, $numMinor, $vLightDir) = @_;
    my $mModelViewMatrix = gltMatrix->new();
    my $vNormal = gltVector3->new();
    my $majorStep = 2.0*GL_PI / $numMajor;
    my $minorStep = 2.0*GL_PI / $numMinor;
    my ($i, $j);

    my @t = glGetFloatv_p(GL_MODELVIEW_MATRIX);
    $mModelViewMatrix->init(\@t);
    #$mModelViewMatrix->Print();
    $vLightDir->Normalize();
    for ($i=0; $i<$numMajor; ++$i) {
        my $a0 = $i * $majorStep;
        my $a1 = $a0 + $majorStep;
        my $x0 = cos($a0);
        my $y0 = sin($a0);
        my $x1 = cos($a1);
        my $y1 = sin($a1);

        glBegin(GL_TRIANGLE_STRIP);
        for ($j=0; $j<=$numMinor; ++$j)  {
            $b = $j * $minorStep;
            my $c = cos($b);
            my $r = $minorRadius * $c + $majorRadius;
            my $z = $minorRadius * sin($b);

                # First point
            $vNormal->[0] = $x0*$c;
            $vNormal->[1] = $y0*$c;
            $vNormal->[2] = $z/$minorRadius;
            $vNormal->Normalize();
	    $vNormal->Rotate($mModelViewMatrix);
            glTexCoord1f($vLightDir->DotProduct($vNormal));
            glVertex3f($x0*$r, $y0*$r, $z);
		#second point
            $vNormal->[0] = $x1*$c;
            $vNormal->[1] = $y1*$c;
            $vNormal->[2] = $z/$minorRadius;
            $vNormal->Normalize();
	    $vNormal->Rotate($mModelViewMatrix);
            glTexCoord1f($vLightDir->DotProduct($vNormal));
            glVertex3f($x1*$r, $y1*$r, $z);
        }
        glEnd();
    } #end for 
}

sub gltDrawTorus {
    my ($majorRadius, $minorRadius, $numMajor, $numMinor) = @_;
    my $vNormal = gltVector3->new();
    my $majorStep = 2.0*GL_PI / $numMajor;
    my $minorStep = 2.0*GL_PI / $numMinor;
    my ($i, $j);

    for ($i=0; $i<$numMajor; ++$i) {
        my $a0 = $i * $majorStep;
        my $a1 = $a0 + $majorStep;
        my $x0 = cos($a0);
        my $y0 = sin($a0);
        my $x1 = cos($a1);
        my $y1 = sin($a1);

        glBegin(GL_TRIANGLE_STRIP);
        for ($j=0; $j<=$numMinor; ++$j)  {
            $b = $j * $minorStep;
            my $c = cos($b);
            my $r = $minorRadius * $c + $majorRadius;
            my $z = $minorRadius * sin($b);

                # First point
            glTexCoord2f($i/$numMajor, $j/$numMinor);
            $vNormal->[0] = $x0*$c;
            $vNormal->[1] = $y0*$c;
            $vNormal->[2] = $z/$minorRadius;
            $vNormal->Normalize();
            glNormal3fv_p($vNormal->[0], $vNormal->[1], $vNormal->[2]);
            glVertex3f($x0*$r, $y0*$r, $z);

            glTexCoord2f(($i+1.0)/$numMajor, $j/$numMinor);
            $vNormal->[0] = $x1*$c;
            $vNormal->[1] = $y1*$c;
            $vNormal->[2] = $z/$minorRadius;
            $vNormal->Normalize();
            glNormal3fv_p($vNormal->[0], $vNormal->[1], $vNormal->[2]);
            glVertex3f($x1*$r, $y1*$r, $z);
        }
        glEnd();
    } #end for 
}

1;
