#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
use OpenGL::Image;
use lib ".";
use gltVector3;
my ($zPos) = (-60.0);

my ($windowWidth, $windowHeight);

my ($w_img, $h_img, $img);
my ($def_ifmt, $def_fmt,$def_type);
my @TextureFiles = ('brick.tga', 'floor.tga', 'ceiling.tga');
my @textures;

use constant   TEXTURE_BRICK => 0;
use constant   TEXTURE_FLOOR => 1;
use constant   TEXTURE_CEILING => 2;
#Управление несколькими текстурами (Тунель)


sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 120.0;

    if($h == 0) {    #предотвращает деление на 0
        $h = 1;
    }

    glViewport(0, 0, $w, $h);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    $fAspect = $w/$h;
    gluPerspective(90.0, $fAspect, 1.0, $nRange);

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
    glTranslatef(0.0, 0.0, $zPos);
	#Теперь рисуем сцену
    DrawTunnel();
    
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
    glBegin(GL_QUADS);
	foreach my $i (0..$#$order) {
	    glTexCoord2f (@{$tex->[$tex_order->[$i]]});
	    #print "Tex".Dumper(\@{$tex->[$tex_order->[$i]]})."\n";
	    glVertex3fv_p(@{$points->[$order->[$i]]});
	    #print "Point:".Dumper(\@{$points->[$order->[$i]]})."\n";
	}
    glEnd();
}

sub DrawTunnel {
    my @tunnel_point = ( 
	gltVector3->new(-10.0,  -10.0,   0.0 ),
	gltVector3->new(-10.0,  -10.0, -10.0 ),
	gltVector3->new( 10.0,  -10.0,   0.0 ),
	gltVector3->new( 10.0,  -10.0, -10.0 ),
	gltVector3->new( 10.0,   10.0,   0.0 ),
	gltVector3->new( 10.0,   10.0, -10.0 ),
	gltVector3->new(-10.0,   10.0,   0.0 ),
	gltVector3->new(-10.0,   10.0, -10.0 )
    );
    my @tunnel_plane = (
	[0, 2, 3, 1],
	[7, 5, 4, 6],
	[0, 1, 7, 6],
	[4, 5, 3, 2]
    );

    my @tex_point = ( 
	[ 0.0,  0.0 ],
	[ 1.0,  1.0 ],
	[ 0.0,  1.0 ],
	[ 1.0,  0.0 ]
    );
    my @tex_plane = (
	[0, 3, 1, 2],
	[2, 1, 3, 0],
	[0, 3, 1, 2],
	[2, 1, 3, 0]
    );

    for(my $z = 60.0; $z >= 0.0; $z -= 10.0) {
	glPushMatrix();
	glTranslatef(0.0, 0.0, $z);
	
	glBindTexture(GL_TEXTURE_2D, $textures[TEXTURE_FLOOR]);
        DrawPlane(\@tunnel_point, $tunnel_plane[0], \@tex_point, $tex_plane[0]);
	glBindTexture(GL_TEXTURE_2D, $textures[TEXTURE_CEILING]);
        DrawPlane(\@tunnel_point, $tunnel_plane[1], \@tex_point, $tex_plane[1]);
	glBindTexture(GL_TEXTURE_2D, $textures[TEXTURE_BRICK]);
        DrawPlane(\@tunnel_point, $tunnel_plane[2], \@tex_point, $tex_plane[2]);
        DrawPlane(\@tunnel_point, $tunnel_plane[3], \@tex_point, $tex_plane[3]);

	glPopMatrix();
    }
}

sub SetupRC {
    my $gluerr;
    
    glEnable(GL_DEPTH_TEST);	#Hidden surface removal
    glEnable(GL_CULL_FACE);	#Do not calculate inside of jet
    glFrontFace(GL_CCW);	#Counter clock-wise polygons face out

    glClearColor(0.0, 0.0, 0.0, 1.0);

    glEnable(GL_TEXTURE_2D);
	#Текструры применяются как переоводные рисунки без эффектов освещения и окрашивания
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	#Texture Load
    @textures = glGenTextures_p($#TextureFiles+1);
    foreach my $i (0..$#TextureFiles) {
	my $name_f =$TextureFiles[$i];
	glBindTexture(GL_TEXTURE_2D, $textures[$i]);
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
    print "Fre textures\n";
    glDeleteTextures_p($#textures+1, \@textures);
}

sub SpecialKeys {
    my ($key, $x, $y) = @_;
    if($key == GLUT_KEY_UP) {
	$zPos += 1.0;
    } elsif($key == GLUT_KEY_DOWN) {
	$zPos -= 1.0;
    }

    glutPostRedisplay();
}

sub OnKey {
    my($key, $x, $y) = @_;
    $key = uc(chr($key));
    #print "press: '".ord($key)."'\n";
    if($key eq "\x1b" or $key eq 'Q') {
	glutLeaveMainLoop();
	#exit(0);
    }
}

sub ProcessMenu {
    my $value = shift;
    if($value == 0) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    } elsif($value == 1) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    } elsif($value == 2) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
    } elsif($value == 3) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
    } elsif($value == 4) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    } elsif($value == 5) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    }
    glutPostRedisplay();
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
glutCreateWindow("Tunnel");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutKeyboardFunc(\&OnKey);
glutDisplayFunc(\&RenderScene);
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("GL_NEAREST", 0);
glutAddMenuEntry("GL_LINEAR", 1);
glutAddMenuEntry("GL_NEAREST_MIPMAP_NEAREST", 2);
glutAddMenuEntry("GL_NEAREST_MIPMAP_LINEAR", 3);
glutAddMenuEntry("GL_LINEAR_MIPMAP_NEAREST", 4);
glutAddMenuEntry("GL_LINEAR_MIPMAP_LINEAR", 5);
glutAttachMenu(GLUT_RIGHT_BUTTON);

SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
    #что то не работатет!!! завершение
glutCloseFunc(\&ShutdownRC);
glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE,GLUT_ACTION_GLUTMAINLOOP_RETURNS);
glutMainLoop();
print "Exit!\n";
ShutdownRC();
exit(0);
