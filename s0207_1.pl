#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use constant GL_PI =>  3.1415;
use lib ".";
use gltVector3;
my ($xRot, $yRot) = (0.0, 0.0);
my $yRotTor = 0.0;

my ($windowWidth, $windowHeight);

sub gltDegToRad {
    return (shift)*(GL_PI/180);
}

sub gltLoadIdentityMatrix {
    my $p_m = shift;	#указатель на массив
    @$p_m = (1.0, 0.0, 0.0, 0.0,
             0.0, 1.0, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0 );
}

    # Creates a 4x4 rotation matrix, takes radians NOT degrees
sub gltRotationMatrix {
    my ($angle, $x, $y, $z, $p_mMatrix) = @_;
    my ($vecLength, $sinSave, $cosSave, $oneMinusCos);
    my ($xx, $yy, $zz, $xy, $yz, $zx, $xs, $ys, $zs);

	#If NULL vector passed in, this will blow up...
    if($x == 0.0 && $y == 0.0 && $z == 0.0) {
        gltLoadIdentityMatrix($p_mMatrix);
        return;
    }

	#Scale vector
    $vecLength = sqrt( $x*$x + $y*$y + $z*$z );

	#Rotation matrix is normalized
    $x /= $vecLength;
    $y /= $vecLength;
    $z /= $vecLength;

    $sinSave = sin($angle);
    $cosSave = cos($angle);
    $oneMinusCos = 1.0 - $cosSave;

    $xx = $x * $x;
    $yy = $y * $y;
    $zz = $z * $z;
    $xy = $x * $y;
    $yz = $y * $z;
    $zx = $z * $x;
    $xs = $x * $sinSave;
    $ys = $y * $sinSave;
    $zs = $z * $sinSave;

    $p_mMatrix->[0]  = ($oneMinusCos * $xx) + $cosSave;
    $p_mMatrix->[4]  = ($oneMinusCos * $xy) - $zs;
    $p_mMatrix->[8]  = ($oneMinusCos * $zx) + $ys;
    $p_mMatrix->[12] = 0.0;

    $p_mMatrix->[1]  = ($oneMinusCos * $xy) + $zs;
    $p_mMatrix->[5]  = ($oneMinusCos * $yy) + $cosSave;
    $p_mMatrix->[9]  = ($oneMinusCos * $yz) - $xs;
    $p_mMatrix->[13] = 0.0;

    $p_mMatrix->[2]  = ($oneMinusCos * $zx) - $ys;
    $p_mMatrix->[6]  = ($oneMinusCos * $yz) + $xs;
    $p_mMatrix->[10] = ($oneMinusCos * $zz) + $cosSave;
    $p_mMatrix->[14] = 0.0;

    $p_mMatrix->[3]  = 0.0;
    $p_mMatrix->[7]  = 0.0;
    $p_mMatrix->[11] = 0.0;
    $p_mMatrix->[15] = 1.0;

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

            glTexCoord2f(($i+1)/$numMajor, $j/$numMinor);
            $vNormal->[0] = $x1*$c;
            $vNormal->[1] = $y1*$c;
            $vNormal->[2] = $z/$minorRadius;
            #glNormal3fv_p(($vNormal));
            $vNormal->Normalize();
            glNormal3fv_p($vNormal->[0], $vNormal->[1], $vNormal->[2]);
            glVertex3f($x1*$r, $y1*$r, $z);
        }
        glEnd();
    } #end for 
}

sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 50.0;
    if($h == 0) {    #предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    $fAspect = $w/$h;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(35.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    my (@transformationMatrix);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    gltRotationMatrix(gltDegToRad($yRotTor), 0.0, 1.0, 0.0, \@transformationMatrix);    
    $transformationMatrix[12] = 0.0;
    $transformationMatrix[13] = 0.0;
    $transformationMatrix[14] = -2.5;
    glLoadMatrixf_p(@transformationMatrix);
    #gltDrawTorus(0.35, 0.15, 20, 10);
    gltDrawTorus(0.35, 0.15, 40, 20);
	#увеличиваем угол поворота
    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $yRotTor += 0.5;
    if($yRotTor > 360.0) {
	$yRotTor -= 360.0;
    }
    
    glutPostRedisplay();
    glutTimerFunc(33, \&TimerFunc, 1);
}

sub SetupRC {
    #glColor3f(0.0, 1.0, 0.0);
    glClearColor(0.0, 0.0, 0.50, 1.0 );

	# Draw everything as wire frame
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
	$xRot -= 5.0;
    } elsif($key == GLUT_KEY_DOWN) {
	$xRot += 5.0;
    } elsif($key == GLUT_KEY_LEFT) {
	$yRot -= 5.0;
    } elsif($key == GLUT_KEY_RIGHT) {
	$yRot += 5.0;
    }
    
    $xRot = 0.0   if($xRot > 356.0);
    $xRot = 355.0 if($xRot < -1.0);
    $yRot = 0.0   if($yRot > 356.0);
    $yRot = 355.0 if($yRot < -1.0);
    
    glutPostRedisplay();
}
sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b" or $key eq 'Q') {
	exit(0);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Rotation Tor");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(33, \&TimerFunc, 1);
glutMainLoop();
