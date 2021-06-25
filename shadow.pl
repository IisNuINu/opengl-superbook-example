#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltVector3;
use gltMatrix;
my ($xRot, $yRot) = (0.0, 0.0);

my ($windowWidth, $windowHeight);

#Освещенный самолет имеющие тени
my @lightPos = ( -75.0, 150.0, -50.0, 0.0 );
my $shadowMat = gltMatrix->new();
my @ground_point = ( 
	gltVector3->new(-30.0,-149.0, -20.0 ),
	gltVector3->new(-30.0,-149.0,  20.0 ),
	gltVector3->new( 40.0,-149.0,  20.0 )
    );
my @ground_plane = (
	[0, 1, 2],
    );


sub ChangeSizeOrtho {
    my ($w, $h) = @_;
    my $aspectRatio;
    my $nRange = 80.0;
    if($h == 0) {    #предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    $aspectRatio = $w/$h;
    if($w <= $h) {
	$windowWidth  = $nRange;
	$windowHeight = $nRange/$aspectRatio;
	glOrtho(-$nRange, $nRange, -$windowHeight, $windowHeight, -$nRange, $nRange);
    } else {
	$windowWidth  = $nRange*$aspectRatio;
	$windowHeight = $nRange;
	glOrtho(-$windowWidth, $windowWidth, -$nRange, $nRange, -$nRange, $nRange);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub ChangeSizePerspect {
    my ($w, $h) = @_;
    my $fAspect;
    my $aObserve = 60.0;	#angle Observe
    my $nRange = 200.0;		#near
    my $fRange = 500.0;		#far

    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }

    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    $fAspect = $w/$h;
    gluPerspective($aObserve, $fAspect, $nRange, $fRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	#Поместим источник света в определенную позицию и сместим начало координат
    glTranslatef(0.0, 0.0, -400.0);
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	#Рисуем поле
    DrawBackground();

    glPushMatrix();
	# // Draw jet at new orientation, put light in correct position
	#// before rotating the jet
    glEnable(GL_LIGHTING);
    glLightfv_p(GL_LIGHT0,GL_POSITION,@lightPos);

    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#Теперь рисуем самолет
    DrawJet(0);
    glPopMatrix();

	#// Get ready to draw the shadow and the ground
	#// First disable lighting and save the projection state
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    glPushMatrix();
    
    #print "Matrix: ".Dumper(\($shadowMat))."\n";
    #$shadowMat->Print();
    glMultMatrixf_p(@$shadowMat);
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#// Pass true to indicate drawing shadow
    DrawJet(1);

	#// Restore the projection to normal
    glPopMatrix();

	#// Draw the light source
    glPushMatrix();
    glTranslatef($lightPos[0],$lightPos[1], $lightPos[2]);
    glColor3ub(255,255,0);
    glutSolidSphere(5.0,10, 10);
    glPopMatrix();

	#// Restore lighting state variables
    glEnable(GL_DEPTH_TEST);


    glutSwapBuffers();
}


sub DrawBackground {
    glBegin(GL_QUADS);
	glColor3ub(0, 32, 0);
	glVertex3f( 400.0, -150.0, -200.0);
	glVertex3f(-400.0, -150.0, -200.0);
	glColor3ub(0, 255, 0);
	glVertex3f(-400.0, -150.0,  200.0);
	glVertex3f( 400.0, -150.0,  200.0);
    glEnd();
}

sub DrawPlane {
    my $points = shift;
    my $order  = shift;
    #print "array points: ".Dumper($points)."\n";
    #print "array order: ".Dumper($order)."\n";
    my $vNormal = gltVector3::gltGetNormalVector($points->[$order->[0]], $points->[$order->[1]], $points->[$order->[2]]);
    glNormal3fv_p(@{$vNormal});
    glVertex3fv_p(@{$points->[$order->[0]]});
    glVertex3fv_p(@{$points->[$order->[1]]});
    glVertex3fv_p(@{$points->[$order->[2]]});
}

sub DrawJet {
    my $is_shadow = shift;
    if($is_shadow) {	#Рисуем тень?
	glColor3ub(0, 0, 0);
	#glColor3ub(128, 128, 128);
    } else {
	glColor3ub(128, 128, 128);
    }
    my @nose_cone_point = ( 
	gltVector3->new( 0.0,   0.0, 60.0 ),
	gltVector3->new(-15.0,  0.0, 30.0 ),
	gltVector3->new( 15.0,  0.0, 30.0 ),
	gltVector3->new(  0.0, 15.0, 30.0 )
    );
    my @nose_cone_plane = (
	[0, 1, 2],
	[2, 3, 0],
	[0, 3, 1]
    );

    my @body_cone_point = ( 
	gltVector3->new(-15.0,  0.0, 30.0 ),
	gltVector3->new(  0.0, 15.0, 30.0 ),
	gltVector3->new( 0.0,   0.0,-56.0 ),
	gltVector3->new( 15.0,  0.0, 30.0 ),
    );
    my @body_cone_plane = (
	[0, 1, 2],
	[2, 1, 3],
	[3, 0, 2]
    );

    my @wing_point = ( 
	gltVector3->new(  0.0,  2.0, 27.0 ),
	gltVector3->new(-60.0,  2.0, -8.0 ),
	gltVector3->new( 60.0,  2.0, -8.0 ),
	gltVector3->new(  0.0,  7.0, -8.0 ),
    );
    my @wing_plane = (
	[0, 1, 2],
	[2, 3, 0],
	[2, 1, 3],
	[0, 3, 1]
    );

    my @wing_tail_point = ( 
	gltVector3->new(-30.0, -0.50, -57.0 ),
	gltVector3->new( 30.0, -0.50, -57.0 ),
	gltVector3->new(  0.0, -0.50, -40.0 ),
	gltVector3->new(  0.0,  4.0, -57.0 ),
    );
    my @wing_tail_plane = (
	[0, 1, 2],
	[2, 1, 3],
	[3, 0, 2],
	[1, 0, 3]
    );

    my @tail_point = ( 
	gltVector3->new(  0.0,  0.50, -40.0 ),
	gltVector3->new(  3.0,  0.50, -57.0 ),
	gltVector3->new(  0.0, 25.0,  -65.0 ),
	gltVector3->new( -3.0,  0.50, -57.0 ),
    );
    my @tail_plane = (
	[0, 1, 2],
	[2, 3, 0],
	[1, 3, 2]
    );



    glBegin(GL_TRIANGLES);
	#--------Nose Cone
	DrawPlane(\@nose_cone_point, $nose_cone_plane[0]);
	DrawPlane(\@nose_cone_point, $nose_cone_plane[1]);
	DrawPlane(\@nose_cone_point, $nose_cone_plane[2]);
	#--------Body of Plane
	DrawPlane(\@body_cone_point, $body_cone_plane[0]);
	DrawPlane(\@body_cone_point, $body_cone_plane[1]);
	DrawPlane(\@body_cone_point, $body_cone_plane[2]);
	#-------- wing
	DrawPlane(\@wing_point, $wing_plane[0]);
	DrawPlane(\@wing_point, $wing_plane[1]);
	DrawPlane(\@wing_point, $wing_plane[2]);
	DrawPlane(\@wing_point, $wing_plane[3]);
	#--------Tail section
	DrawPlane(\@wing_tail_point, $wing_tail_plane[0]);
	DrawPlane(\@wing_tail_point, $wing_tail_plane[1]);
	DrawPlane(\@wing_tail_point, $wing_tail_plane[2]);
	DrawPlane(\@wing_tail_point, $wing_tail_plane[3]);
	#--------Top of tail section left
	DrawPlane(\@tail_point, $tail_plane[0]);
	DrawPlane(\@tail_point, $tail_plane[1]);
	DrawPlane(\@tail_point, $tail_plane[2]);
	
    glEnd();
}

sub SetupRC {
    my $points = [
	$ground_point[$ground_plane[0]->[0]], 
        $ground_point[$ground_plane[0]->[1]],
	$ground_point[$ground_plane[0]->[2]]
    ];

    my @ambientLight = (0.3, 0.3, 0.3, 1.0);
    my @diffuseLight = (0.7, 0.7, 0.7, 1.0);
    my @specular     = (1.0, 1.0, 1.0, 1.0);
    my @specref      = (1.0, 1.0, 1.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet

	#// Lighting stuff
    glEnable(GL_LIGHTING);	# Enable lighting
	#// Set light model to use ambient light specified by ambientLight
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );    
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE,  @diffuseLight );    
    glLightfv_p(GL_LIGHT0, GL_SPECULAR, @specular );    
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos );    
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

	# Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
	#с этого момента все материалы получают способность отражать блики
    glMaterialfv_p(GL_FRONT, GL_SPECULAR, @specref);
    glMateriali(GL_FRONT, GL_SHININESS, 128);

    glClearColor(0.0, 0.0, 1.0, 1.0);
	#Calculate projection matrix to draw shadow on the ground
    $shadowMat->MakeShadowMatrix($points, \@lightPos);
    #print "Matrix: Shadow\n";
    #$shadowMat->Print();
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
glutCreateWindow("Shadow");
glutReshapeFunc(\&ChangeSizePerspect);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
