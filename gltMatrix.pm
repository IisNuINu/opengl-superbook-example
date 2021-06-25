package gltMatrix;
require Exporter;
@ISA=qw(Exporter);
#@EXPORT= qw();

sub new {
    my $class = shift;
    my $self = bless( [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], $class );
    return $self;
}

sub init {
    my ($self, $m) = @_;
    @$self = @$m;
    return $self;
}

sub Identity {
    my ($self) = @_;
    @$self = (1.0, 0.0, 0.0, 0.0,
              0.0, 1.0, 0.0, 0.0,
              0.0, 0.0, 1.0, 0.0,
              0.0, 0.0, 0.0, 1.0 );
    return $self;
}

sub Print {
    my ($self) = @_;
    print "0=$self->[0],\t1=$self->[1],\t2=$self->[2],\t3=$self->[3]\n";
    print "4=$self->[4],\t5=$self->[5],\t6=$self->[6],\t7=$self->[7]\n";
    print "8=$self->[8],\t9=$self->[9],\t10=$self->[10],\t11=$self->[11]\n";
    print "12=$self->[12],\t13=$self->[13],\t14=$self->[14],\t15=$self->[15]\n";
}

sub MakeRotation {
    my ($self, $angle, $x, $y, $z) = @_;
    my ($vecLength, $sinSave, $cosSave, $oneMinusCos);
    my ($xx, $yy, $zz, $xy, $yz, $zx, $xs, $ys, $zs);

	#If NULL vector passed in, this will blow up...
    if($x == 0.0 && $y == 0.0 && $z == 0.0) {
        $self->Identity();
        return;
    }

	#Scale vector
    $vecLength = sqrt( $x*$x + $y*$y + $z*$z );

	#Rotation matrix is normalized
    $x /= $vecLength;
    $y /= $vecLength;
    $z /= $vecLength;

    $sinSave = sin($angle);
    $cosSave = cos($angle);
    $oneMinusCos = 1.0 - $cosSave;

    $xx = $x * $x;
    $yy = $y * $y;
    $zz = $z * $z;
    $xy = $x * $y;
    $yz = $y * $z;
    $zx = $z * $x;
    $xs = $x * $sinSave;
    $ys = $y * $sinSave;
    $zs = $z * $sinSave;

    $self->[0]  = ($oneMinusCos * $xx) + $cosSave;
    $self->[4]  = ($oneMinusCos * $xy) - $zs;
    $self->[8]  = ($oneMinusCos * $zx) + $ys;
    $self->[12] = 0.0;

    $self->[1]  = ($oneMinusCos * $xy) + $zs;
    $self->[5]  = ($oneMinusCos * $yy) + $cosSave;
    $self->[9]  = ($oneMinusCos * $yz) - $xs;
    $self->[13] = 0.0;

    $self->[2]  = ($oneMinusCos * $zx) - $ys;
    $self->[6]  = ($oneMinusCos * $yz) + $xs;
    $self->[10] = ($oneMinusCos * $zz) + $cosSave;
    $self->[14] = 0.0;

    $self->[3]  = 0.0;
    $self->[7]  = 0.0;
    $self->[11] = 0.0;
    $self->[15] = 1.0;
}

sub gltLoadIdentityMatrix {
    my $p_m = shift;	#указатель на массив
    @$p_m = glTMatrix::new()->Identity()
}

sub MakeShadowMatrix {
    my ($self, $vPoints, $vLightPos) = @_;

    my @PlaneEquation = gltVector3::gltGetPlaneEquation($vPoints->[0], $vPoints->[1], $vPoints->[2]);

	#// Dot product of plane and light position
    my $dot =   $PlaneEquation[0] * $vLightPos->[0] +
                $PlaneEquation[1] * $vLightPos->[1] +
        	$PlaneEquation[2] * $vLightPos->[2] +
        	$PlaneEquation[3] * $vLightPos->[3];
	#First Column
    $self->[0] = $dot - $vLightPos->[0] * $PlaneEquation[0];
    $self->[4] = 0.0  - $vLightPos->[0] * $PlaneEquation[1];
    $self->[8] = 0.0  - $vLightPos->[0] * $PlaneEquation[2];
    $self->[12]= 0.0  - $vLightPos->[0] * $PlaneEquation[3];
	#Second Column
    $self->[1] = 0.0  - $vLightPos->[1] * $PlaneEquation[0];
    $self->[5] = $dot - $vLightPos->[1] * $PlaneEquation[1];
    $self->[9] = 0.0  - $vLightPos->[1] * $PlaneEquation[2];
    $self->[13]= 0.0  - $vLightPos->[1] * $PlaneEquation[3];
	#Thrid Column
    $self->[2] =  0.0  - $vLightPos->[2] * $PlaneEquation[0];
    $self->[6] =  0.0  - $vLightPos->[2] * $PlaneEquation[1];
    $self->[10] = $dot - $vLightPos->[2] * $PlaneEquation[2];
    $self->[14]=  0.0  - $vLightPos->[2] * $PlaneEquation[3];
	#Fourth Column
    $self->[3] =  0.0  - $vLightPos->[3] * $PlaneEquation[0];
    $self->[7] =  0.0  - $vLightPos->[3] * $PlaneEquation[1];
    $self->[11] = 0.0  - $vLightPos->[3] * $PlaneEquation[2];
    $self->[15]=  $dot - $vLightPos->[3] * $PlaneEquation[3];
}


1;
