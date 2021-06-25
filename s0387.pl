#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use OpenGL::Image;
use lib ".";
use gltVector3;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);
my @sizes; # = (0.0, 0.0);        #Допустимые размеры точек ОпенГЛ
my $step;                #минимальный поддерживаемый инкремент размеров точек

my ($w_img, $h_img, $img);
my ($def_ifmt, $def_fmt,$def_type);


#Рисуем пирамиду, первый опыт с текстурами

sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 40.0;
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
    glTranslatef(0.0, -0.25, -4.0);
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 1.0, 0.0);
	#Теперь рисуем сцену
    DrawPyramid();
    
    glPopMatrix();

    glutSwapBuffers();
}

sub DrawPlane {
    my $points = shift;
    my $order  = shift;
    my $tex    = shift;
    my $tex_order = shift;
    #print "array points: ".Dumper($points)."\n";
    #print "array order: ".Dumper($order)."\n";
    my $vNormal = gltVector3::gltGetNormalVector($points->[$order->[0]], $points->[$order->[1]], $points->[$order->[2]]);
    glNormal3fv_p(@{$vNormal});
    glTexCoord2f (@{$tex->[$tex_order->[0]]});
    glVertex3fv_p(@{$points->[$order->[0]]});
    glTexCoord2f (@{$tex->[$tex_order->[1]]});
    glVertex3fv_p(@{$points->[$order->[1]]});
    glTexCoord2f (@{$tex->[$tex_order->[2]]});
    glVertex3fv_p(@{$points->[$order->[2]]});
}

sub DrawPyramid {
    my @pyramid_point = ( 
	gltVector3->new( 0.0,  0.8, 0.0 ),
	gltVector3->new(-0.5,  0.0,-0.5 ),
	gltVector3->new( 0.5,  0.0,-0.5 ),
	gltVector3->new( 0.5,  0.0, 0.5 ),
	gltVector3->new(-0.5,  0.0, 0.5 )
    );
    my @pyramid_plane = (
	[2, 4, 1],
	[2, 3, 4],
	[0, 4, 3],
	[0, 1, 4],
	[0, 2, 1],
	[0, 3, 2]
    );

    my @tex_point = ( 
	[ 0.0,  0.0 ],
	[ 0.0,  1.0 ],
	[ 1.0,  1.0 ],
	[ 1.0,  0.0 ],
	[ 0.5,  1.0 ]
    );
    my @tex_plane = (
	[2, 0, 1],
	[2, 3, 0],
	[4, 0, 3],
	[4, 0, 3],
	[4, 0, 3],
	[4, 0, 3]
    );


    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_TRIANGLES);
	foreach my $i (0..$#pyramid_plane) {
	    DrawPlane(\@pyramid_point, $pyramid_plane[$i], \@tex_point, $tex_plane[$i]);
	}
    glEnd();
}

sub SetupRC {
    my @whiteLight  = (0.05, 0.05, 0.05, 1.0);
    my @sourceLight = (0.25, 0.25, 0.25, 1.0);
    my @lightPos    = (-10.0, 5.0,  5.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out

	#// Lighting stuff
    glEnable(GL_LIGHTING);	# Enable lighting
	#устанавливаем и активизируем источник света 0
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @whiteLight);
    glLightfv_p(GL_LIGHT0, GL_AMBIENT, @sourceLight );    
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE, @sourceLight );
    glLightfv_p(GL_LIGHT0, GL_POSITION, @lightPos);
    glEnable(GL_LIGHT0);

    glEnable(GL_COLOR_MATERIAL); # Enable Material color tracking

	# Front material ambient and diffuse colors track glColor
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
    glClearColor(0.0, 0.0, 0.0, 1.0);

	#Texture Load
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    $img = new OpenGL::Image(source=>'stone.tga');
    ($w_img,$h_img) = $img->Get('width','height');
    ($def_ifmt, $def_fmt,$def_type) = $img->Get('gl_internalformat', 'gl_format','gl_type');
	#Texture set
    glTexImage2D_c(GL_TEXTURE_2D, 0, $def_ifmt, $w_img, $h_img, 0, $def_fmt, $def_type,$img->Ptr() );
    #glTexImage2D_c(GL_TEXTURE_2D, 0, $def_ifmt, $w_img, $h_img, 0, $def_fmt, GL_UNSIGNED_BYTE, $img->Ptr() );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glEnable(GL_TEXTURE_2D);
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
    if($key eq "\x1b" or $key eq 'Q') {
	exit(0);
    }
}

eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Textured Pyramid");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
