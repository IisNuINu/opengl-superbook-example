#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use OpenGL::Image;
use lib ".";
use gltCommon qw/GL_PI/;
use gltVector3;
#use gltTools qw/gltDrawUnitAxes/;
my ($xRot, $yRot, $zRot) = (0.0, 0.0, 0.0);

my ($windowWidth, $windowHeight);

#Рисуем БОЛТ
sub RenderThread {
    my ($x, $y, $z, $angle);
    my $height = 75.0;
    my $diameter = 20.0;
    my $vNormal; # = gltVector3->new();
    my @vCorners= (
	gltVector3->new(),
	gltVector3->new(),
	gltVector3->new(),
	gltVector3->new()
    );
    my $step = GL_PI/32.0;
    my ($revolutions, $threadWidth, $threadThick) = (7.0, 2.0, 3.0);
    my $zstep = 0.125;
    
       # Set material color for head of screw
    glColor3f(0.0, 0.0, 0.4);

    $z = -$height/2.0+2.0;  # Starting spot almost to the end
    for($angle=0.0; $angle < GL_PI*2.0*$revolutions; $angle += $step) {
	    # Calculate x and y position of the next vertex
	$x = $diameter*sin($angle);
	$y = $diameter*cos($angle);
        $vCorners[0]->init([$x, $y, $z]);

            # Calculate the position away from the shaft
        $x = ($diameter+$threadWidth)*sin($angle);
        $y = ($diameter+$threadWidth)*cos($angle);
        $vCorners[1]->init([$x, $y, $z]);

            # Calculate the next position away from the shaft
        $x = ($diameter+$threadWidth)*sin($angle+$step);
        $y = ($diameter+$threadWidth)*cos($angle+$step);
        $vCorners[2]->init([$x, $y, $z+$zstep]);

            # Calculate the next position along the shaft
        $x = ($diameter)*sin($angle+$step);
        $y = ($diameter)*cos($angle+$step);
        $vCorners[3]->init([$x, $y, $z+$zstep]);

            # We'll be using triangels, so make
            # counter clock-wise polygons face out
        glFrontFace(GL_CCW);
        glBegin(GL_TRIANGLES);  # Start the top section of thread

            # Calculate the normal for this segment
    	    $vNormal = gltVector3::gltGetNormalVector($vCorners[0], $vCorners[1], $vCorners[2]);
    	    glNormal3fv_p(@$vNormal);

            # Draw two triangles to cover area
    	    glVertex3fv_p(@{$vCorners[0]});
    	    glVertex3fv_p(@{$vCorners[1]});
    	    glVertex3fv_p(@{$vCorners[2]});

    	    glVertex3fv_p(@{$vCorners[2]});
    	    glVertex3fv_p(@{$vCorners[3]});
    	    glVertex3fv_p(@{$vCorners[0]});
        glEnd();

            # Move the edge along the shaft slightly up the z axis
            # to represent the bottom of the thread
        $vCorners[0]->[2] += $threadThick;
        $vCorners[3]->[2] += $threadThick;

            # Recalculate the normal since points have changed, this
            # time it points in the opposite direction, so reverse it
    	$vNormal = gltVector3::gltGetNormalVector($vCorners[0], $vCorners[1], $vCorners[2]);
	$vNormal->Scale(-1);

            # Switch to clock-wise facing out for underside of the
            # thread.
        glFrontFace(GL_CW);

            # Draw the two triangles
        glBegin(GL_TRIANGLES);
            glNormal3fv_p(@$vNormal);

            glVertex3fv_p(@{$vCorners[0]});
            glVertex3fv_p(@{$vCorners[1]});
            glVertex3fv_p(@{$vCorners[2]});

            glVertex3fv_p(@{$vCorners[2]});
            glVertex3fv_p(@{$vCorners[3]});
            glVertex3fv_p(@{$vCorners[0]});
        glEnd();

            # Creep up the Z axis
        $z += $zstep;
    }

} 

sub RenderShaft {
    my ($x, $z, $angle);
    my $height = 75.0;
    my $diameter = 20.0;
    my $vNormal = gltVector3->new();
    my @vCorners= (
	gltVector3->new(),
	gltVector3->new()
    );
    my $step = GL_PI/50.0;
    
       # Set material color for head of screw
    glColor3f(0.0, 0.0, 0.7);
	# First assemble the wall as 100 quadrilaterals formed by
        # placing adjoining Quads together
    glFrontFace(GL_CCW);
    glBegin(GL_QUAD_STRIP);

    for($angle=2.0*GL_PI; $angle > 0.0; $angle -= $step) {
	    # Calculate x and y position of the next vertex
	$x = $diameter*sin($angle);
	$z = $diameter*cos($angle);
            # Get the coordinate for this point and extrude the
            # length of the cylinder.
        $vCorners[0]->init([$x, -$height/2.0, $z]);
        $vCorners[1]->init([$x,  $height/2.0, $z]);

        $vNormal->init([$vCorners[1]->[0],  0.0, $vCorners[1]->[2]]);
	$vNormal->Normalize;
    	
	glNormal3fv_p(@$vNormal);
    	glVertex3fv_p(@{$vCorners[0]});
    	glVertex3fv_p(@{$vCorners[1]});
    }
        # Make sure there are no gaps by extending last quad to
        # the original location
    $x = $diameter*sin(2.0*GL_PI);
    $z = $diameter*cos(2.0*GL_PI);
    glVertex3fv_p($x, -$height/2.0, $z);
    glVertex3fv_p($x,  $height/2.0, $z);

    glEnd();

        # Begin a new triangle fan to cover the bottom
    glBegin(GL_TRIANGLE_FAN);
        # Normal points down the Y axis
	glNormal3f(0.0, -1.0, 0.0);

        # Center of fan is at the origin
	glVertex3f(0.0, -$height/2.0, 0.0);
	for($angle=2.0*GL_PI; $angle > 0.0; $angle -= $step) {
            # Calculate x and y position of the next vertex
    	    $x = $diameter*sin($angle);
    	    $z = $diameter*cos($angle);
	    glVertex3fv_p($x, -$height/2.0, $z);

	}
            # Be sure loop is closed by specifiying initial vertex
            # on arc as the last too
	$x = $diameter*sin(2.0*GL_PI);
	$z = $diameter*cos(2.0*GL_PI);
	glVertex3fv_p($x, -$height/2.0, $z);
    glEnd();

} 


sub RenderHead {
    my ($x, $y, $angle);
    my $height = 25.0;
    my $diameter = 30.0;
    my $vNormal = gltVector3->new();
    my @vCorners= (
	gltVector3->new(),
	gltVector3->new(),
	gltVector3->new(),
	gltVector3->new()
    );
    my $step = GL_PI/3.0;
    
       # Set material color for head of screw
    glColor3f(0.0, 0.0, 0.7);
	# First assemble the wall as 100 quadrilaterals formed by
        # placing adjoining Quads together
    glFrontFace(GL_CCW);
        # Begin a new triangle fan to cover the bottom
    glBegin(GL_TRIANGLE_FAN);
        # Normal points down the Z axis
	glNormal3f(0.0, 0.0, 1.0);

        # Center of fan is at the origin
	glVertex3f(0.0, 0.0, $height/2.0);
	# First and Last vertex closes the fan
	glVertex3f(0.0, $diameter, $height/2.0);
	for($angle=2.0*GL_PI-$step; $angle >= 0.0; $angle -= $step) {
            # Calculate x and y position of the next vertex
    	    $x = $diameter*sin($angle);
    	    $y = $diameter*cos($angle);
	    glVertex3fv_p($x, $y, $height/2.0);

	}
    	# Last vertex closes the fan
	glVertex3f(0.0, $diameter, $height/2.0);
    glEnd();

        # Begin a new triangle fan to cover the bottom
    glBegin(GL_TRIANGLE_FAN);
        # Normal points down the Z axis
	glNormal3f(0.0, 0.0, -1.0);

        # Center of fan is at the origin
	glVertex3f(0.0, 0.0, -$height/2.0);
	for($angle=0.0; $angle < 2.0*GL_PI; $angle += $step) {
            # Calculate x and y position of the next vertex
    	    $x = $diameter*sin($angle);
    	    $y = $diameter*cos($angle);
	    glVertex3f($x, $y, -$height/2.0);
	}
    	# Last vertex closes the fan
	glVertex3f(0.0, $diameter, -$height/2.0);
    glEnd();



    glBegin(GL_QUADS);

    for($angle=0.0; $angle < 2.0*GL_PI; $angle += $step) {
	    # Calculate x and y position of the next vertex
	$x = $diameter*sin($angle);
	$y = $diameter*cos($angle);
            # Get the coordinate for this point and extrude the
            # length of the cylinder.
        $vCorners[0]->init([$x, $y, -$height/2.0]);
        $vCorners[1]->init([$x, $y,  $height/2.0]);
	    #Calculate the next hex point
	$x = $diameter*sin($angle+$step);
	$y = $diameter*cos($angle+$step);
        if($angle+$step < GL_PI*2.0) {
    	    $vCorners[2]->init([$x, $y, $height/2.0]);
    	    $vCorners[3]->init([$x, $y, -$height/2.0]);
	} else {
            # We aren't done, the points at the top and bottom
            # of the head.
    	    $vCorners[2]->init([0.0, $diameter, $height/2.0]);
    	    $vCorners[3]->init([0.0, $diameter, -$height/2.0]);
	}
    	$vNormal = gltVector3::gltGetNormalVector($vCorners[0], $vCorners[1], $vCorners[2]);
    	
	glNormal3fv_p(@$vNormal);
    	glVertex3fv_p(@{$vCorners[0]});
    	glVertex3fv_p(@{$vCorners[1]});
    	glVertex3fv_p(@{$vCorners[2]});
    	glVertex3fv_p(@{$vCorners[3]});
    }
    glEnd();
} 



sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    my $nRange = 100.0;
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

sub RenderScene {
    my ($x, $y, $z, $angle);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	glRotatef($xRot, 1.0, 0.0, 0.0);
	glRotatef($yRot, 0.0, 1.0, 0.0);
	glRotatef($zRot, 0.0, 0.0, 1.0);
	
	    #Render just the Thread of the nut
        RenderShaft();
	glPushMatrix();
	    glRotatef(-90.0, 1.0, 0.0, 0.0);
    	    RenderThread();
	    #glRotatef(-90.0, 1.0, 0.0, 0.0);
    	    glTranslatef(0.0, 0.0, 45.0);
        RenderHead();
	glPopMatrix();
    glPopMatrix();

    glutSwapBuffers();
}


sub SetupRC {
    my @ambientLight = (0.3, 0.3, 0.3, 1.0);
    my @diffuseLight = (0.7, 0.7, 0.7, 1.0);
    my @specular     = (0.9, 0.9, 0.9, 1.0);
    my @lightPos     = (-50.0, 200.0, 200.0, 1.0);
    my @specref      = (0.6, 0.6, 0.6, 1.0);

    glEnable(GL_DEPTH_TEST);    #Hidden surface removal
    glEnable(GL_CULL_FACE);     #Do not calculate inside of jet
    glFrontFace(GL_CCW);        #Counter clock-wise polygons face out

        #// Lighting stuff
    glEnable(GL_LIGHTING);      # Enable lighting
       #// Supply a slight ambient light so the objects can be seen
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @ambientLight);
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE,  @diffuseLight );
    glLightfv_p(GL_LIGHT0, GL_SPECULAR, @specular );

        # Position and turn on the light
    glLightfv_p(GL_LIGHT0,GL_POSITION,@lightPos);
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

        # Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
        #с этого момента все материалы получают способность отражать блики
    glMaterialfv_p(GL_FRONT, GL_SPECULAR, @specref);
    glMateriali(GL_FRONT, GL_SHININESS, 64);

    glClearColor(1.0, 1.0, 1.0, 1.0);
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
    
    $xRot %= 360.0;
    $yRot %= 360.0;
    
    glutPostRedisplay();
}

sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b") {
	exit(0);
    }
    if($key eq 'Q') {
	$zRot -= 5.0;
    } elsif( $key eq 'A') {
	$zRot += 5.0;
    }
    $zRot %= 360.0;
    glutPostRedisplay();
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Bolt Assembly");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
