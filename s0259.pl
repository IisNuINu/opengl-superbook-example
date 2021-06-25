#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltVector3;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);
my @sizes; # = (0.0, 0.0);        #Допустимые размеры точек ОпенГЛ
my $step;                #минимальный поддерживаемый инкремент размеров точек

#Освещенный самолет имеющие отражательные свойстава(блики)

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
    my $nRange = 1000.0;
    my @lightPos = ( -50.0, 50.0, 100.0, 1.0 );

    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }

    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    $fAspect = $w/$h;
    gluPerspective(35.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	#Поместим источник света в определенную позицию и сместим начало координат
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);
    glTranslatef(0.0, 0.0, -150.0);

}

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    #glMatrixMode(GL_MODELVIEW);
    #glLoadIdentity();
    glPushMatrix();
    	#Транслируем всю сцену в поле зрения наблюдателя
	#Это исходное преобразование наблюдения
	#установим нужный ракурс   
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#Теперь рисуем сцену
    DrawJet();
    
    glPopMatrix();

    glutSwapBuffers();
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
	glColor3ub(128, 128, 128);
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
    my @ambientLight = (0.3, 0.3, 0.3, 1.0);
    my @diffuseLight = (0.7, 0.7, 0.7, 1.0);
    my @specular     = (1.0, 1.0, 1.0, 1.0);
    my @specref      = (1.0, 1.0, 1.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out

	#// Lighting stuff
    glEnable(GL_LIGHTING);	# Enable lighting
	#// Set light model to use ambient light specified by ambientLight
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );    
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE,  @diffuseLight );    
    glLightfv_p(GL_LIGHT0, GL_SPECULAR, @specular );    
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

	# Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
	#с этого момента все материалы получают способность отражать блики
    glMaterialfv_p(GL_FRONT, GL_SPECULAR, @specref);
    glMateriali(GL_FRONT, GL_SHININESS, 128);

    glClearColor(0.0, 0.0, 1.0, 1.0);
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
glutCreateWindow("Jet");
glutReshapeFunc(\&ChangeSizeOrtho);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
