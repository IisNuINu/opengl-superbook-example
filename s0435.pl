#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use OpenGL::Image;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI gltDegToRad/;
use gltVector3;
use gltMatrix;
use gltTorus qw/gltDrawTorus/;
use gltSphere qw/gltDrawSphere/;
use gltFrame;

my ($xRot, $yRot) = (0.0, 0.0);
my $yRotTor = 0.0;

my $NUM_SPHERES=20;
my @spheres;

my ($windowWidth, $windowHeight);
my $frameCamera;

    #// Light and material Data
my @lightPos = ( -100.0, 100.0, 50.0, 0.0 );
my @noLight = ( 0.0, 0.0, 0.0, 0.0 );
my @lowLight = ( 0.25, 0.25, 0.25, 1.0 );
my @brightLight = ( 1.0, 1.0, 1.0, 1.0 );


my $shadowMat = gltMatrix->new();
my @ground_point = (
        gltVector3->new( 0.0,  -0.4,  0.0 ),
        gltVector3->new( 10.0, -0.4,  0.0 ),
        gltVector3->new( 5.0,  -0.4, -5.0 )
    );
my @ground_plane = (
        [0, 1, 2],
    );

#Textures
my ($w_img, $h_img, $img);
my ($def_ifmt, $def_fmt,$def_type);
my @TextureFiles = ('grass.tga', 'wood.tga', 'orb.tga');
my @textureObjects;

use constant   GROUND_TEXTURE => 0;
use constant   TORUS_TEXTURE  => 1;
use constant   SPHERE_TEXTURE => 2;


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

    gluPerspective(35.0, $fAspect, 0.1, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub DrawInhabitants {
    my $is_shadow = shift;
    if($is_shadow) {
	#glColor4f(1.0, 1.0, 1.0, 0.10);	
	glColor4f(0.0, 0.0, 0.0, 0.4);	
	#glColor3f(0.0, 0.0, 0.0);	
    } 
	#Рисуем статические сферы
    if(!$is_shadow) {
	glColor4f(1.0, 1.0, 1.0, 1.0);	
    }
    glBindTexture(GL_TEXTURE_2D, $textureObjects[SPHERE_TEXTURE]);
    foreach my $s (@spheres) {
	glPushMatrix();
	$s->ApplyActorTransform();
	#glutSolidSphere(0.3, 17, 9);
	gltDrawSphere(0.3, 17, 9);
	glPopMatrix();
    }
    
    glPushMatrix();
	#---------------------!!!!!!!! Обращаю вниманиена 0.1 из за него тор рисуется над! землей
    glTranslatef(0.0, 0.1, -2.5);
	#Рисуем вращающуюся сферу
    glPushMatrix();
	glRotatef(-$yRotTor*2.0, 0.0, 1.0, 0.0);
	glTranslatef(1.0, 0.0, 0.0);
	#glutSolidSphere(0.1, 17, 9);
	gltDrawSphere(0.1, 17, 9);
    glPopMatrix();
	#Рисуем ТОР
    if(!$is_shadow) {
	#glColor3f(1.0, 0.0, 0.0);	
        glMaterialfv_p(GL_FRONT, GL_SPECULAR, @brightLight);
    }
    glRotatef($yRotTor, 0.0, 1.0, 0.0);
    glBindTexture(GL_TEXTURE_2D, $textureObjects[TORUS_TEXTURE]);
    gltDrawTorus(0.35, 0.15, 40, 20);
    glMaterialfv_p(GL_FRONT, GL_SPECULAR, @noLight);

    glPopMatrix();
}

sub RenderScene {
    my ($transformationMatrix);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    glPushMatrix();
	$frameCamera->ApplyCameraTransform();
        glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);    
	    #Draw the ground
        glColor3f(1.00, 1.0, 1.0);
        #DrawGroundOld();
        DrawGround();
    	    #// Draw shadows first
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_LIGHTING);
        glDisable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_STENCIL_TEST);
        glPushMatrix();
	    glMultMatrixf_p(@$shadowMat);
            DrawInhabitants(1);
        glPopMatrix();
        glDisable(GL_STENCIL_TEST);
        glDisable(GL_BLEND);

        glEnable(GL_DEPTH_TEST);
	glColor3f(1.0, 1.0, 1.0);
	DrawAxis();

        glEnable(GL_LIGHTING);
        glEnable(GL_TEXTURE_2D);

    	    #// Draw inhabitants normally
        DrawInhabitants(0);
    glPopMatrix();

    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $yRotTor += 1.0;
    if($yRotTor > 360.0) {
	$yRotTor -= 360.0;
    }
    
    glutPostRedisplay();
    glutTimerFunc(3, \&TimerFunc, 1);
}

sub SetupRC {
    my $gluerr;
    my $points = [
        $ground_point[$ground_plane[0]->[0]],
        $ground_point[$ground_plane[0]->[1]],
        $ground_point[$ground_plane[0]->[2]]
    ];

    glClearColor($lowLight[0], $lowLight[1], $lowLight[2], $lowLight[3] );
	#// Clear stencil buffer with zero, increment by one whenever anybody
	#// draws into it. When stencil function is enabled, only write where
	#// stencil value is zero. This prevents the transparent shadow from drawing
	#// over itself
    glStencilOp(GL_INCR, GL_INCR, GL_INCR);
    glClearStencil(0);
    glStencilFunc(GL_EQUAL, 0x0, 0x01);

	#// Cull backs of polygons
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_MULTISAMPLE_ARB);

	#// Setup light parameters
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @noLight);
    glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR);
    glLightfv_p(GL_LIGHT0, GL_AMBIENT, @lowLight);
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE, @brightLight);
    glLightfv_p(GL_LIGHT0, GL_SPECULAR,@brightLight);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

        #Calculate projection matrix to draw shadow on the ground
    $shadowMat->MakeShadowMatrix($points, \@lightPos);
	#// Mostly use material tracking
    glEnable(GL_COLOR_MATERIAL);
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
    glMateriali(GL_FRONT, GL_SHININESS, 128);

    $frameCamera = gltFrame->new();
	#Randomly place the sphere inhabitants
    for(my $iSphere = 0; $iSphere < $NUM_SPHERES; $iSphere++) {
	my $s = gltFrame->new();
	$s->{vLocation}->[0] = rand(40)-20;
	$s->{vLocation}->[1] =  0.0;
	$s->{vLocation}->[2] = rand(40)-20;
	push @spheres, $s;
    }
	#Textures load
    glEnable(GL_TEXTURE_2D);
    @textureObjects = glGenTextures_p($#TextureFiles+1);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    foreach my $i (0..$#TextureFiles) {
        my $name_f =$TextureFiles[$i];
        glBindTexture(GL_TEXTURE_2D, $textureObjects[$i]);
        $img = new OpenGL::Image(source=>$name_f);
        ($w_img,$h_img) = $img->Get('width','height');
        ($def_ifmt, $def_fmt,$def_type) = $img->Get('gl_internalformat', 'gl_format','gl_type');
            #Texture set
        if ($gluerr =gluBuild2DMipmaps_c(GL_TEXTURE_2D,  $def_ifmt, $w_img, $h_img, $def_fmt,
              $def_type,$img->Ptr() )) {
            printf STDERR "GLULib%s\n", gluErrorString($gluerr);
            exit(-1);
        }
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }

}

sub ShutdownRC {
    print "Free textures\n";
    glDeleteTextures_p($#textureObjects+1, \@textureObjects);
}


sub DrawAxis {
        #Нарисуем 3 оси Х, У, Z
    glBegin(GL_LINES);
        glVertex3f(100.0, 0.0, 0.0);
        glVertex3f(-100.0, 0.0, 0.0);
    glEnd();
    glBegin(GL_LINES);
        glVertex3f(0.0,  100.0, 0.0);
        glVertex3f(0.0, -100.0, 0.0);
    glEnd();
    glBegin(GL_LINES);
        glVertex3f(0.0,  0.0,  100.0);
        glVertex3f(0.0,  0.0, -100.0);
    glEnd();
}

sub DrawGround {
    my $fExtent = 20.0;
    my $fStep   = 1.0;
    my $y       = -0.4;
    my ($iStrip, $iRun);
    
    my ($s, $t) = (0.0, 0.0);
    my $texStep = 1.0/($fExtent * 0.075);

    glBindTexture(GL_TEXTURE_2D, $textureObjects[GROUND_TEXTURE]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    for($iStrip = -$fExtent; $iStrip <= $fExtent; $iStrip += $fStep) {
	$t = 0.0;
	glBegin(GL_TRIANGLE_STRIP);
	for($iRun = $fExtent; $iRun >= -$fExtent; $iRun -= $fStep) {
	    glTexCoord2f($s, $t);
	    glNormal3f(0.0, 1.0, 0.0);	#All Point UP
	    glVertex3f($iStrip,        $y,  $iRun);

	    glTexCoord2f($s+$texStep, $t);
	    glNormal3f(0.0, 1.0, 0.0);	#All Point UP
	    glVertex3f($iStrip+$fStep, $y,  $iRun);
	    $t += $texStep;
	}
	glEnd();
	$s += $texStep;
    }
}


sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
	#print "forward 0.1\n";
	$frameCamera->MoveForward(0.1);
    } elsif($key == GLUT_KEY_DOWN) {
	#print "forward -0.1\n";
	$frameCamera->MoveForward(-0.1);
    } elsif($key == GLUT_KEY_LEFT) {
	#print "Rotate Y 0.1\n";
	$frameCamera->RotateLocalY(0.1);
    } elsif($key == GLUT_KEY_RIGHT) {
	#print "Rotate Y -0.1\n";
	$frameCamera->RotateLocalY(-0.1);
    }
    #$frameCamera->print('Camera');
    
    glutPostRedisplay();
}
sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	#glutTimerFunc(0, 0, 0);
	#glutLeaveMainLoop();
	ShutdownRC();
	exit(0);
    }
    if($key eq 'T') {
	$frameCamera->clear();
    } elsif( $key eq 'Q') {
	$frameCamera->MoveUp(0.1);
    } elsif( $key eq 'A') {
	$frameCamera->MoveUp(-0.1);
    } elsif( $key eq 'W') {
	$frameCamera->RotateLocalX(-0.1);
    } elsif( $key eq 'S') {
	$frameCamera->RotateLocalX(0.1);
    } elsif( $key eq 'E') {
	$frameCamera->RotateLocalZ(-0.1);
    } elsif( $key eq 'R') {
	$frameCamera->RotateLocalZ(0.1);
    } elsif( $key eq 'D') {
	$frameCamera->MoveRight(0.1);
    } elsif( $key eq 'F') {
	$frameCamera->MoveRight(-0.1);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH | GLUT_STENCIL);
glutInitWindowSize(800, 600);
glutCreateWindow("OpenGL SphereWord Demo + Texture Maps");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutTimerFunc(33, \&TimerFunc, 1);
#glutCloseFunc(\&ShutdownRC);
glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE,GLUT_ACTION_GLUTMAINLOOP_RETURNS);
glutMainLoop();
ShutdownRC();
print "The End.\n";
