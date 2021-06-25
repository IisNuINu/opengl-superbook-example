package gltTools;
require Exporter;
@ISA=qw(Exporter);
@EXPORT_OK= qw(gltDrawUnitAxes);
use OpenGL qw/ :all/;
use Data::Dumper;
#use constant GL_PI =>  3.1415;
use gltCommon qw/GL_PI/;
use gltVector3;
use gltMatrix;

sub gltDrawUnitAxes {
    my $pObj;
    my $fAxisRadius = 0.025;
    my $fAxisHeight = 1.0;
    my $fArrowRadius = 0.06;
    my $fArrowHeight = 0.1;

	#Setup the quadric object
    $pObj = gluNewQuadric();
    gluQuadricDrawStyle($pObj, GLU_FILL);
    gluQuadricNormals  ($pObj, GLU_SMOOTH);
    gluQuadricOrientation($pObj, GLU_OUTSIDE);
    gluQuadricTexture($pObj, GLU_FALSE);

        #// Draw the blue Z axis first, with arrowed head
    glColor3f(0.0, 0.0, 1.0);
    gluCylinder($pObj, $fAxisRadius, $fAxisRadius, $fAxisHeight, 10, 1);
    glPushMatrix();
	glTranslatef(0.0, 0.0, 1.0);
	gluCylinder($pObj, $fArrowRadius, 0.0, $fArrowHeight, 10, 1);
	glRotatef(180.0, 1.0, 0.0, 0.0);
	gluDisk($pObj, $fAxisRadius, $fArrowRadius, 10, 1);
    glPopMatrix();

        #// Draw the Red X axis 2nd, with arrowed head
    glColor3f(1.0, 0.0, 0.0);
    glPushMatrix();
        glRotatef(90.0, 0.0, 1.0, 0.0);
        gluCylinder($pObj, $fAxisRadius, $fAxisRadius, $fAxisHeight, 10, 1);
        glTranslatef(0.0, 0.0, 1.0);
        gluCylinder($pObj, $fArrowRadius, 0.0, $fArrowHeight, 10, 1);
	glRotatef(180.0, 0.0, 1.0, 0.0);
        gluDisk($pObj, $fAxisRadius, $fArrowRadius, 10, 1);
    glPopMatrix();
    
        #// Draw the Green Y axis 3rd, with arrowed head
    glColor3f(0.0, 1.0, 0.0);
    glPushMatrix();
        glRotatef(-90.0, 1.0, 0.0, 0.0);
        gluCylinder($pObj, $fAxisRadius, $fAxisRadius, $fAxisHeight, 10, 1);
        glTranslatef(0.0, 0.0, 1.0);
        gluCylinder($pObj, $fArrowRadius, 0.0, $fArrowHeight, 10, 1);
	glRotatef(180.0, 1.0, 0.0, 0.0);
        gluDisk($pObj, $fAxisRadius, $fArrowRadius, 10, 1);
    glPopMatrix();

        #// White Sphere at origin
    glColor3f(1.0, 1.0, 1.0);
    gluSphere($pObj, 0.05, 15, 15);

        #// Delete the quadric
    gluDeleteQuadric($pObj);
}

1;
