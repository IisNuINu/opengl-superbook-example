#!/usr/bin/perl -w
use strict;
use OpenGL qw/ :all/;
use OpenGL::Image;
use Data::Dumper;
#use constant GL_PI =>  3.1415;
use lib ".";
use gltCommon qw/GL_PI gltDegToRad/;
use gltVector3;
use gltMatrix;
use gltTorus qw/gltDrawTorus/;

my ($xRot, $yRot) = (0.0, 0.0);
my $yRotTor = 0.0;

my ($windowWidth, $windowHeight);

my ($w_img, $h_img, $img);
my ($def_ifmt, $def_fmt,$def_type);
my @TextureFiles = ('stripes.tga', 'environment.tga');
my @toTextures;
my $iRenderMode = 3;
my $toQuit = 0;
my $Window_ID;

sub ChangeSize {
    my ($w, $h) = @_;
    my $fAspect;
    my $nRange = 225.0;
    if($h == 0) {    #предотвращает деление на 0
	$h = 1;
    }
    glViewport(0, 0, $w, $h);
    $fAspect = $w/$h;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluPerspective(45.0, $fAspect, 1.0, $nRange);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

sub RenderScene {
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	#Переключаемся на ортографическую проекцию для фонового рисования
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    gluOrtho2D(0.0, 1.0, 0.0, 1.0);    
    glMatrixMode(GL_MODELVIEW);
    glBindTexture(GL_TEXTURE_2D, $toTextures[1]);
	#фоновая текстура
	#Задаем текстурные координаты
    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);
    glDepthMask(GL_FALSE);
	#фоновое изображение
    glBegin(GL_QUADS);
	glTexCoord2f (0.0, 0.0);
	glVertex2fv_p(0.0, 0.0);
	glTexCoord2f (1.0, 0.0);
	glVertex2fv_p(1.0, 0.0);
	glTexCoord2f (1.0, 1.0);
	glVertex2fv_p(1.0, 1.0);
	glTexCoord2f (0.0, 1.0);
	glVertex2fv_p(0.0, 1.0);
    glEnd();

	#возвращаемся к трехмерному основанию
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
	#включаем генерацию текстур и запись в буффер глубины
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
    glDepthMask(GL_TRUE);
	#Возможно потребуется окаймить текстуру
    if($iRenderMode != 3) {
        glBindTexture(GL_TEXTURE_2D, $toTextures[0]);
    }
    glPushMatrix();
        glTranslatef(0.0, 0.0, -2.0);
	glRotatef($xRot, 1.0, 0.0, 0.0);
	glRotatef($yRot, 0.0, 1.0, 0.0);
        glRotatef($yRotTor, 0.0, 1.0, 0.0);
	gltDrawTorus(0.35, 0.15, 40, 20);
    glPopMatrix();

    glutSwapBuffers();
}

sub TimerFunc {
    my $val= shift;

    $yRotTor += 0.5;
    if($yRotTor > 360.0) {
	$yRotTor -= 360.0;
    }
    if(!$toQuit) {
	glutPostRedisplay();
	glutTimerFunc(33, \&TimerFunc, 1);
    }
}

sub SetupRC {
    
    glEnable(GL_DEPTH_TEST);    #Hidden surface removal
    glEnable(GL_CCW);    	
    glEnable(GL_CULL_FACE);     #Do not calculate inside of jet
	#Белый фон
    glClearColor(1.0, 1.0, 1.0, 1.0 );
	#Маркировка текструной среды
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
        #Texture Load
    @toTextures = glGenTextures_p($#TextureFiles+1);    
    foreach my $i (0..$#TextureFiles) {
        my $name_f =$TextureFiles[$i];
        glBindTexture(GL_TEXTURE_2D, $toTextures[$i]);
        $img = new OpenGL::Image(source=>$name_f);
        ($w_img,$h_img) = $img->Get('width','height');
        ($def_ifmt, $def_fmt,$def_type) = $img->Get('gl_internalformat', 'gl_format','gl_type');
            #Texture set
        glTexImage2D_c(GL_TEXTURE_2D,  0, $def_ifmt, $w_img, $h_img, 0, $def_fmt, $def_type, $img->Ptr() );

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    glEnable(GL_TEXTURE_2D);

	#Включение генерации текстурных координат
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);

    	#по умолчанию Отображение сферы
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
}

sub ShutdownRC {
    print "Free textures\n";
    glDeleteTextures_p($#toTextures+1, \@toTextures);
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
	print "to Quit\n";
	$toQuit = 1;
	#glutPostRedisplay();
	#glutTimerFunc(0, \eval{;}, 0);
        glutLeaveMainLoop();
	#exit(0);
    }
}

sub ProcessMenu {
    my $value = shift;
    my @zPlane= (0.0, 0.0, 1.0, 0.0);
    $iRenderMode = $value;
    if($value == 1) {		#Линейный по объектам
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	glTexGenfv_p(GL_S, GL_OBJECT_PLANE, @zPlane);
	glTexGenfv_p(GL_T, GL_OBJECT_PLANE, @zPlane);
    } elsif($value == 2) {	#Линейный по наблюдению
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
	glTexGenfv_p(GL_S, GL_OBJECT_PLANE, @zPlane);
	glTexGenfv_p(GL_T, GL_OBJECT_PLANE, @zPlane);
    } elsif($value == 3) {	#Отображение сферы
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    }
    glutPostRedisplay();
}


eval {glutInit(); 1} or die qq { This test requires GLUT };
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
glutInitWindowSize(800, 600);
$Window_ID = glutCreateWindow("Texture Coordinate Generator");
glutReshapeFunc(\&ChangeSize);
glutSpecialFunc(\&SpecialKeys);
glutDisplayFunc(\&RenderScene);
glutKeyboardFunc(\&OnKey);
SetupRC();
    #Создание меню
glutCreateMenu(\&ProcessMenu);
glutAddMenuEntry("Object Linear", 1);
glutAddMenuEntry("Eye Linear", 2);
glutAddMenuEntry("Sphere Linear", 3);
glutAttachMenu(GLUT_RIGHT_BUTTON);
glutTimerFunc(33, \&TimerFunc, 1);
glutCloseFunc(\&ShutdownRC);
glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE,GLUT_ACTION_GLUTMAINLOOP_RETURNS);
glutMainLoop();
ShutdownRC();
