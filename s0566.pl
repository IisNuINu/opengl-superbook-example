#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use Data::Dumper;
my ($xRot, $yRot) = (0.0, 0.0);
my $fElect1 = 0.0;

my ($windowWidth, $windowHeight);
my @sizes; # = (0.0, 0.0);        #Допустимые размеры точек ОпенГЛ
my $step;                #минимальный поддерживаемый инкремент размеров точек
my @corners = (
    [-25.0, 25.0, 25.0],
    [ 25.0, 25.0, 25.0],
    [ 25.0,-25.0, 25.0],
    [-25.0,-25.0, 25.0],
    [-25.0, 25.0,-25.0],
    [ 25.0, 25.0,-25.0],
    [ 25.0,-25.0,-25.0],
    [-25.0,-25.0,-25.0]
);

my @indexes = (
    [ 0, 1, 2, 3],	#Front face
    [ 4, 5, 1, 0],	#Top face
    [ 3, 2, 6, 7],	#Bottom face
    [ 5, 4, 7, 6],	#Back face
    [ 1, 5, 6, 2],	#Right face
    [ 4, 0, 3, 7]	#Left face
);

my ($a_corners, $a_indexes);

sub ChangeSizeOrtho {
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
	glOrtho(-$nRange, $nRange, -$windowHeight, $windowHeight, $nRange, -$nRange);
    } else {
	$windowWidth  = $nRange*$aspectRatio;
	$windowHeight = $nRange;
	glOrtho(-$windowWidth, $windowWidth, -$nRange, $nRange, $nRange, -$nRange);
    }
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub ChangeSizePerspect {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 1000.0;
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
	# Make the cube a wire frame
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    	#Транслируем всю сцену в поле зрения наблюдателя
	#Это исходное преобразование наблюдения
	#Отойдем от центра "вселенной"
    glTranslatef(0.0, 0.0, -200.0); 
	#и установим нужный ракурс   
    glRotatef($xRot, 1.0, 0.0, 0.0);
    glRotatef($yRot, 0.0, 0.0, 1.0);
	#Теперь рисуем сцену
	#// Enable and specify the vertex array
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer_c(3, GL_FLOAT, 0, $a_corners->ptr());

	# Using Drawarrays
    glDrawElements_c(GL_QUADS, 24, GL_UNSIGNED_BYTE, $a_indexes->ptr());
    
    glPopMatrix();

    glutSwapBuffers();
}


sub SetupRC {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glColor3ub(0, 0, 0);
    
    $a_corners = OpenGL::Array->new_list(GL_FLOAT, map { @$_ } @corners);
    $a_indexes = OpenGL::Array->new_list(GL_BYTE,  map { @$_ } @indexes);
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
glutCreateWindow("CubeDX");
glutReshapeFunc(\&ChangeSizePerspect);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
#glutTimerFunc(100, \&TimerFunc, 1);
glutMainLoop();
