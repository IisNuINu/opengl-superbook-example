#!/usr/bin/perl -w

use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use lib ".";
use gltCommon qw/GL_PI/;

use constant SCREEN_X =>  800;
use constant SCREEN_Y =>  600;

my ($xRot, $yRot) = (45.0, 60.0);

my @ctrlPoint = (
    [ 
	[-4.0, 0.0, 4.0],
	[-2.0, 4.0, 4.0],
	[ 4.0, 0.0, 4.0]
    ],	
    [ 
	[-4.0, 0.0, 0.0],
	[-2.0, 4.0, 0.0],
	[ 4.0, 0.0, 0.0]
    ],	
    [ 
	[-4.0, 0.0,-4.0],
	[-2.0, 4.0,-4.0],
	[ 4.0, 0.0,-4.0]
    ]	
);

sub DrawPoints {
    glPointSize(5.0);
    glBegin(GL_POINTS);
    foreach my $plane (@ctrlPoint) {
	#print "P".Dumper($p)."\n";
	foreach my $p (@$plane) {
    	    #glVertex3fv_p($p->[0], $p->[1], $p->[3]);
    	    glVertex3fv_p(@$p);
	}
    }
    glEnd();
}

sub RenderScene {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    my ($start, $end, $size_point, $size_slice) = (0, 10, 3, 3);
    my @tmp = map { map {@$_ } @$_ } @ctrlPoint;
    print "tmp:\n".Dumper(\@tmp)."\n";
    #glMap1f_p(GL_MAP1_VERTEX_3, $start, $end, $size, $#ctrlPoint+1, \@tmp);
    #glMap1f_p(GL_MAP1_VERTEX_3, 0.0, 100.0, 3, $#ctrlPoint+1, \@tmp);
	#ага  функция glMap1f_p реализована не верно хотя вызывать по идее ее надо так
	#glMap1f_p(GL_MAP1_VERTEX_3, 0.0, 100.0, @tmp);
    	# вызов в OpenGL.xs выглядит так, что неправильно передает информацию о size:
	# glMap1f(target, u1, u2, 0, order, points);
	# но зато есть другие функции ими и воспользуемся
    my $numFloatVar = ($#ctrlPoint+1) *$size_point*$size_slice;
    my $t = pack("f$numFloatVar", @tmp);
    
	#// Save the modelview matrix stack
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();

	    #// Rotate the mesh around to make it easier to see
	#glRotatef(45.0, 0.0, 1.0, 0.0);
	#glRotatef(60.0, 1.0, 0.0, 0.0);
        glRotatef($xRot, 1.0, 0.0, 0.0);
        glRotatef($yRot, 0.0, 1.0, 0.0);

	glMap2f_s(GL_MAP2_VERTEX_3,   		# Type of data generated
	    $start,                           	# Lower u range
	    $end,                              	# Upper u range
	    $size_point,                        # Distance between points in the data
	    $size_point,                        # Dimension in u direction (order)
	    $start,                           	# Lover v range
	    $end,                              	# Upper v range
	    $size_point*$size_slice,            # Distance between points in the data
	    $size_point,                        # Dimension in v direction (order)
	    $t);              			# array of control points

	    #// Enable the evaluator
	glEnable(GL_MAP2_VERTEX_3);
	    #// Use higher level functions to map to a grid, then evaluate the
	    #// entire thing.
	    #// Map a grid of 10 points from 0 to 10
	glMapGrid2f($end, $start, $end, $end, $start, $end);
	    #// Evaluate the grid, using lines
	glEvalMesh2(GL_FILL, $start, $end, $start, $end);

	    #Рисуем контрольные точки
	DrawPoints();

    glPopMatrix();

    glutSwapBuffers();
}

sub SetupRC {
    my @ambientLight = (0.3, 0.3, 0.3, 1.0);
    my @diffuseLight = (0.7, 0.7, 0.7, 1.0);

	#White background
    glClearColor(1.0, 1.0, 1.0, 1.0);

    glEnable(GL_DEPTH_TEST);    #Hidden surface removal

        #// Lighting stuff
    glEnable(GL_LIGHTING);      # Enable lighting
        #// Set light model to use ambient light specified by ambientLight
    glLightfv_p(GL_LIGHT0, GL_AMBIENT,  @ambientLight );
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE,  @diffuseLight );
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
	# Automatically generate normals for evaluated surfaces
    glEnable(GL_AUTO_NORMAL);
    
	#Blue drawing
    glColor3f(0.0, 0.0, 1.0);
}


sub ChangeSize {
    my ($w, $h) = @_;
    my $aspectRatio;
    my @lightPos = ( 20.0, 0.0, 0.0, 0.0 );
    my $nRange = 10.0;
    if($h == 0) {	#предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$nRange, $nRange, -$nRange, $nRange, -$nRange, $nRange);    

    glMatrixMode(GL_MODELVIEW);
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);
    glLoadIdentity();
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
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(SCREEN_X, SCREEN_Y);
glutCreateWindow("Lit 3D Bezier Surface");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
glutMainLoop();
