package ship_data;

our @face_indicies = (
	[ 51,47,65 ,0,0,0 ,0,1,2  ],
	[ 65,69,51 ,0,0,0 ,2,3,0  ],
	[ 67,48,51 ,1,1,1 ,4,5,6  ],
	[ 51,69,67 ,1,1,1 ,6,7,4  ],
	[ 86,85,27 ,2,2,2 ,8,9,10  ],
	[ 27,28,86 ,2,2,2 ,10,11,8  ],
	[ 28,2,4 ,3,4,3 ,12,13,14  ],
	[ 4,29,28 ,3,5,3 ,14,15,12  ],
	[ 1,27,26 ,6,7,6 ,16,17,18  ],
	[ 26,3,1 ,6,8,6 ,18,19,16  ],
	[ 85,105,102 ,9,10,9 ,20,21,22  ],
	[ 102,84,85 ,9,11,9 ,22,23,20  ],
	[ 59,55,54 ,1,1,1 ,24,25,26  ],
	[ 54,58,59 ,1,1,1 ,26,27,24  ],
	[ 62,44,45 ,12,12,12 ,28,29,30  ],
	[ 45,61,62 ,12,12,12 ,30,31,28  ],
	[ 49,68,50 ,1,1,1 ,32,33,34  ],
	[ 66,50,68 ,1,1,1 ,35,34,33  ],
	[ 86,28,29 ,1,1,1 ,36,37,38  ],
	[ 29,87,86 ,1,1,1 ,38,39,36  ],
	[ 27,85,84 ,13,13,13 ,40,41,42  ],
	[ 84,26,27 ,13,13,13 ,42,43,40  ],
	[ 52,57,56 ,14,14,14 ,44,45,46  ],
	[ 56,53,52 ,14,14,14 ,46,47,44  ],
	[ 90,91,81 ,15,15,15 ,48,49,50  ],
	[ 81,80,90 ,15,15,15 ,50,51,48  ],
	[ 21,22,14 ,15,15,15 ,52,53,54  ],
	[ 14,13,21 ,15,15,15 ,54,55,52  ],
	[ 106,86,87 ,16,17,16 ,56,57,58  ],
	[ 87,103,106 ,16,18,16 ,58,59,56  ],
	[ 93,92,82 ,19,19,19 ,60,61,62  ],
	[ 82,83,93 ,19,19,19 ,62,63,60  ],
	[ 25,23,15 ,19,19,19 ,64,65,66  ],
	[ 15,16,25 ,19,19,19 ,66,67,64  ],
	[ 7,12,5 ,20,20,20 ,68,69,70  ],
	[ 7,11,12 ,20,20,20 ,68,71,69  ],
	[ 7,5,11 ,20,20,20 ,68,70,71  ],
	[ 96,100,95 ,20,20,20 ,72,73,74  ],
	[ 96,98,100 ,20,20,20 ,72,75,73  ],
	[ 96,95,98 ,20,20,20 ,72,74,75  ],
	[ 48,19,47 ,21,22,21 ,76,77,78  ],
	[ 47,51,48 ,21,23,21 ,78,79,76  ],
	[ 88,67,69 ,24,25,24 ,77,80,81  ],
	[ 69,65,88 ,24,26,24 ,81,78,77  ],
	[ 0,1,3 ,27,27,27 ,82,83,84  ],
	[ 3,4,0 ,27,27,27 ,84,85,82  ],
	[ 105,106,103 ,28,28,28 ,86,87,88  ],
	[ 103,104,105 ,28,28,28 ,88,89,86  ],
	[ 55,52,53 ,23,23,23 ,90,91,92  ],
	[ 53,54,55 ,23,23,23 ,92,93,90  ],
	[ 57,59,58 ,29,29,29 ,91,94,93  ],
	[ 58,56,57 ,29,29,29 ,93,92,91  ],
	[ 93,91,90 ,29,29,29 ,95,96,97  ],
	[ 90,92,93 ,29,29,29 ,97,98,95  ],
	[ 83,82,80 ,23,23,23 ,95,98,97  ],
	[ 80,81,83 ,23,23,23 ,97,96,95  ],
	[ 44,43,42 ,23,30,31 ,99,100,101  ],
	[ 42,45,44 ,31,23,23 ,101,102,99  ],
	[ 43,32,33 ,30,32,33 ,100,103,104  ],
	[ 33,42,43 ,33,31,30 ,104,101,100  ],
	[ 78,63,60 ,34,35,36 ,103,100,105  ],
	[ 60,79,78 ,36,37,34 ,105,106,103  ],
	[ 63,62,61 ,35,29,29 ,100,107,108  ],
	[ 61,60,63 ,29,36,35 ,108,105,100  ],
	[ 25,22,21 ,29,29,29 ,95,96,97  ],
	[ 21,23,25 ,29,29,29 ,97,109,95  ],
	[ 16,15,13 ,23,23,23 ,95,98,97  ],
	[ 13,14,16 ,23,23,23 ,97,96,95  ],
	[ 20,49,46 ,38,39,39 ,110,111,112  ],
	[ 50,46,49 ,23,39,39 ,113,112,111  ],
	[ 68,89,66 ,25,40,40 ,114,115,116  ],
	[ 64,66,89 ,41,40,40 ,117,116,115  ],
	[ 106,105,85 ,42,43,42 ,118,119,120  ],
	[ 85,86,106 ,42,44,42 ,120,121,118  ],
	[ 28,27,1 ,45,46,45 ,122,123,124  ],
	[ 1,2,28 ,45,47,45 ,124,125,122  ],
	[ 103,87,84 ,48,49,50 ,126,127,128  ],
	[ 84,102,103 ,50,48,48 ,128,129,126  ],
	[ 87,29,26 ,49,51,52 ,127,130,131  ],
	[ 26,84,87 ,52,50,49 ,131,128,127  ],
	[ 29,4,3 ,51,53,53 ,130,132,133  ],
	[ 3,26,29 ,53,52,51 ,133,131,130  ],
	[ 55,59,57 ,54,54,54 ,134,135,136  ],
	[ 57,52,55 ,54,54,54 ,136,137,134  ],
	[ 54,53,56 ,55,55,55 ,138,139,140  ],
	[ 56,58,54 ,55,55,55 ,140,141,138  ],
	[ 92,90,80 ,56,56,56 ,142,143,144  ],
	[ 80,82,92 ,56,56,56 ,144,145,142  ],
	[ 91,93,83 ,57,57,57 ,146,147,148  ],
	[ 83,81,91 ,57,57,57 ,148,149,146  ],
	[ 62,63,43 ,58,59,60 ,150,151,152  ],
	[ 43,44,62 ,60,58,58 ,152,153,150  ],
	[ 63,78,32 ,59,61,61 ,151,154,155  ],
	[ 32,43,63 ,61,60,59 ,155,152,151  ],
	[ 23,21,13 ,56,56,56 ,156,157,158  ],
	[ 13,15,23 ,56,56,56 ,158,159,156  ],
	[ 24,25,16 ,57,57,57 ,160,161,162  ],
	[ 16,14,24 ,57,57,57 ,162,163,160  ],
	[ 5,10,6 ,62,62,62 ,164,165,166  ],
	[ 5,12,10 ,63,63,63 ,167,168,165  ],
	[ 12,9,10 ,29,29,29 ,169,165,165  ],
	[ 12,11,9 ,29,29,29 ,169,170,165  ],
	[ 11,6,9 ,64,64,64 ,169,171,165  ],
	[ 11,5,6 ,64,64,64 ,169,167,171  ],
	[ 8,6,10 ,1,1,1 ,172,171,165  ],
	[ 8,10,9 ,1,1,1 ,172,165,165  ],
	[ 8,9,6 ,1,1,1 ,172,165,171  ],
	[ 95,101,94 ,65,65,65 ,173,174,175  ],
	[ 95,100,101 ,66,66,66 ,176,177,178  ],
	[ 100,99,101 ,29,29,29 ,179,178,178  ],
	[ 100,98,99 ,29,29,29 ,179,180,178  ],
	[ 98,94,99 ,64,64,64 ,179,181,178  ],
	[ 98,95,94 ,64,64,64 ,179,176,181  ],
	[ 97,94,101 ,1,1,1 ,182,181,178  ],
	[ 97,101,99 ,1,1,1 ,182,178,178  ],
	[ 97,99,94 ,1,1,1 ,182,178,181  ],
	[ 35,39,34 ,66,66,66 ,183,184,185  ],
	[ 35,41,39 ,67,67,67 ,186,187,188  ],
	[ 41,38,39 ,29,29,29 ,189,188,188  ],
	[ 41,40,38 ,29,29,29 ,189,189,188  ],
	[ 40,34,38 ,68,68,68 ,189,190,188  ],
	[ 40,35,34 ,68,68,68 ,189,186,190  ],
	[ 36,34,39 ,1,1,1 ,191,190,188  ],
	[ 36,39,38 ,1,1,1 ,191,188,188  ],
	[ 36,38,34 ,1,1,1 ,191,188,190  ],
	[ 71,75,70 ,66,66,66 ,192,193,194  ],
	[ 71,77,75 ,67,67,67 ,195,196,197  ],
	[ 77,74,75 ,29,29,29 ,198,197,197  ],
	[ 77,76,74 ,29,29,29 ,198,198,197  ],
	[ 76,70,74 ,68,68,68 ,198,194,197  ],
	[ 76,71,70 ,68,68,68 ,198,195,194  ],
	[ 72,70,75 ,1,1,1 ,199,194,197  ],
	[ 72,75,74 ,1,1,1 ,199,197,197  ],
	[ 72,74,70 ,1,1,1 ,199,197,194  ],
	[ 48,67,88 ,54,54,54 ,200,200,201  ],
	[ 88,17,48 ,54,54,54 ,201,201,200  ],
	[ 60,42,31 ,69,69,69 ,202,203,204  ],
	[ 31,79,60 ,69,69,69 ,204,205,202  ],
	[ 30,78,79 ,70,70,70 ,206,207,208  ],
	[ 79,31,30 ,70,70,70 ,208,209,206  ],
	[ 37,41,35 ,20,20,20 ,210,211,212  ],
	[ 37,40,41 ,20,20,20 ,210,213,211  ],
	[ 37,35,40 ,20,20,20 ,210,214,213  ],
	[ 73,77,71 ,20,20,20 ,210,215,212  ],
	[ 73,76,77 ,20,20,20 ,210,213,215  ],
	[ 73,71,76 ,20,20,20 ,210,214,213  ],
	[ 68,49,89 ,71,71,71 ,216,217,218  ],
	[ 18,89,49 ,71,71,71 ,219,218,217  ],
	[ 19,88,65 ,72,72,72 ,220,221,222  ],
	[ 65,47,19 ,72,72,72 ,222,223,220  ],
	[ 46,50,64 ,73,73,73 ,223,224,222  ],
	[ 66,64,50 ,73,73,73 ,225,222,224  ],
	[ 61,45,42 ,74,74,74 ,226,227,228  ],
	[ 42,60,61 ,74,74,74 ,228,229,226  ],
	[ 89,20,64 ,75,75,75 ,230,231,232  ],
	[ 46,64,20 ,75,75,75 ,233,232,231  ]
); #end face_indicies
our @normals = (
	[ 0.0,0.169524,0.985526 ],
	[ 0.0,1.0,0.0 ],
	[ 0.0,0.52395,-0.851749 ],
	[ -0.476576,0.879116,0.005585 ],
	[ -0.478776,0.877866,0.011171 ],
	[ -0.474357,0.880332,0.0 ],
	[ 0.40881,-0.897845,-0.16355 ],
	[ 0.502754,-0.805534,-0.313614 ],
	[ 0.298567,-0.954363,-0.006966 ],
	[ -0.465953,-0.864051,-0.190535 ],
	[ -0.449091,-0.891594,-0.058108 ],
	[ -0.474158,-0.820453,-0.319423 ],
	[ 0.0,0.999643,0.026703 ],
	[ 0.0,-0.931867,-0.362799 ],
	[ 0.0,-0.965964,-0.258675 ],
	[ 0.0,-0.999979,0.006417 ],
	[ 0.49373,0.868979,0.033251 ],
	[ 0.473096,0.881011,0.0 ],
	[ 0.513535,0.855492,0.066447 ],
	[ 0.0,0.999966,0.00823 ],
	[ 0.0,-1.0,0.0 ],
	[ -0.977414,0.043808,0.206741 ],
	[ -0.910678,0.085637,0.404143 ],
	[ -1.0,0.0,0.0 ],
	[ 0.972556,0.085192,0.21651 ],
	[ 0.995608,0.093623,0.0 ],
	[ 0.903329,0.072717,0.42274 ],
	[ -0.999728,0.0,0.023326 ],
	[ 0.991733,0.0,0.128321 ],
	[ 1.0,0.0,-2e-006 ],
	[ -0.991188,0.121908,-0.051824 ],
	[ -0.997688,0.064231,-0.022218 ],
	[ -0.981069,0.172287,-0.088432 ],
	[ -0.980236,0.182064,-0.077397 ],
	[ 0.980213,0.182009,-0.077821 ],
	[ 0.997817,0.062408,-0.021587 ],
	[ 0.991177,0.121872,-0.052108 ],
	[ 0.979877,0.177578,-0.091148 ],
	[ -0.910678,0.085637,-0.404143 ],
	[ -0.977414,0.043808,-0.206741 ],
	[ 0.972556,0.085192,-0.21651 ],
	[ 0.903329,0.072717,-0.42274 ],
	[ -0.320358,0.261362,-0.910528 ],
	[ -0.348268,0.0,-0.937395 ],
	[ -0.270083,0.504478,-0.820096 ],
	[ 0.329563,0.279843,-0.901707 ],
	[ 0.065086,0.522839,-0.849943 ],
	[ 0.550645,0.0,-0.83474 ],
	[ 0.5628,0.0,0.826593 ],
	[ 0.195276,0.0,0.980748 ],
	[ 0.390551,0.0,0.920581 ],
	[ -0.385969,0.0,0.922512 ],
	[ -0.192984,0.0,0.981202 ],
	[ -0.556743,0.0,0.830685 ],
	[ 0.0,0.0,-1.0 ],
	[ 0.0,0.168506,0.985701 ],
	[ 0.0,0.154448,-0.988001 ],
	[ 0.0,0.039242,0.99923 ],
	[ 0.0,-0.007276,-0.999974 ],
	[ 0.0,-0.354817,-0.934936 ],
	[ 0.0,-0.181163,-0.983453 ],
	[ 0.0,-0.512085,-0.858935 ],
	[ -0.500002,0.0,0.866024 ],
	[ -0.499999,-1e-006,0.866026 ],
	[ -0.500001,0.0,-0.866025 ],
	[ -0.500001,0.0,0.866025 ],
	[ -0.5,0.0,0.866025 ],
	[ -0.500001,-1e-006,0.866025 ],
	[ -0.5,0.0,-0.866025 ],
	[ 0.0,0.501708,0.865037 ],
	[ 0.0,-0.88965,0.456643 ],
	[ 0.0,0.0,1.0 ],
	[ 0.0,-0.488232,0.872714 ],
	[ 0.0,0.169524,-0.985526 ],
	[ 0.0,-0.003837,0.999993 ],
	[ 0.0,-0.488233,-0.872713 ]
); #end normals
our @textures = (
	[ 0.846339,0.673143 ],
	[ 0.773436,0.673143 ],
	[ 0.773436,0.509194 ],
	[ 0.846339,0.509194 ],
	[ 0.863242,0.509194 ],
	[ 0.863242,0.673143 ],
	[ 0.846339,0.673143 ],
	[ 0.846339,0.509194 ],
	[ 0.83369,0.464792 ],
	[ 0.914127,0.464792 ],
	[ 0.914127,0.717545 ],
	[ 0.83369,0.717545 ],
	[ 0.83369,0.717545 ],
	[ 1.01785,0.996576 ],
	[ 0.976838,0.995619 ],
	[ 0.790375,0.717545 ],
	[ 1.01785,0.996576 ],
	[ 0.914127,0.717545 ],
	[ 0.790375,0.717545 ],
	[ 0.976838,0.995619 ],
	[ 0.914127,0.464792 ],
	[ 1.01785,0.185761 ],
	[ 0.976838,0.191065 ],
	[ 0.790375,0.464792 ],
	[ 0.791976,0.524523 ],
	[ 0.791976,0.657814 ],
	[ 0.756294,0.657814 ],
	[ 0.756294,0.524523 ],
	[ 0.989221,0.50982 ],
	[ 0.989221,0.675094 ],
	[ 0.954011,0.675094 ],
	[ 0.954011,0.50982 ],
	[ 0.862946,0.673143 ],
	[ 0.862946,0.509194 ],
	[ 0.87985,0.673143 ],
	[ 0.87985,0.509194 ],
	[ 0.57694,0.623077 ],
	[ 0.57694,0.424975 ],
	[ 0.546653,0.424975 ],
	[ 0.546653,0.623077 ],
	[ 0.633183,0.424975 ],
	[ 0.633183,0.623077 ],
	[ 0.546653,0.623077 ],
	[ 0.546653,0.424975 ],
	[ 0.547773,0.471791 ],
	[ 0.547773,0.576262 ],
	[ 0.507581,0.576262 ],
	[ 0.507581,0.471791 ],
	[ 0.660871,0.650138 ],
	[ 0.536047,0.650138 ],
	[ 0.536047,0.622185 ],
	[ 0.660871,0.622185 ],
	[ 0.660871,0.422475 ],
	[ 0.536047,0.422475 ],
	[ 0.536047,0.394522 ],
	[ 0.660871,0.394522 ],
	[ 1.01785,0.185761 ],
	[ 0.83369,0.464792 ],
	[ 0.790375,0.464792 ],
	[ 0.976838,0.191065 ],
	[ 0.787769,0.430266 ],
	[ 0.903394,0.430266 ],
	[ 0.903394,0.465931 ],
	[ 0.787769,0.465931 ],
	[ 0.787769,0.720735 ],
	[ 0.903394,0.720735 ],
	[ 0.903394,0.7564 ],
	[ 0.787769,0.7564 ],
	[ 0.986863,0.981811 ],
	[ 0.97934,0.97747 ],
	[ 0.986863,0.990494 ],
	[ 0.994387,0.97747 ],
	[ 0.986864,0.199384 ],
	[ 0.97934,0.195042 ],
	[ 0.986864,0.208067 ],
	[ 0.994387,0.195042 ],
	[ 0.015138,0.115077 ],
	[ 0.594539,0.115077 ],
	[ 0.43537,0.028575 ],
	[ 0.015138,0.098795 ],
	[ 0.015138,0.115077 ],
	[ 0.015138,0.098795 ],
	[ 0.657918,0.263992 ],
	[ 0.771653,0.263992 ],
	[ 0.771653,0.224494 ],
	[ 0.657918,0.224494 ],
	[ 0.771653,0.263992 ],
	[ 0.657918,0.263992 ],
	[ 0.657918,0.224493 ],
	[ 0.771653,0.224493 ],
	[ 0.561438,0.046434 ],
	[ 0.67261,0.046434 ],
	[ 0.687873,-0.00893295 ],
	[ 0.561438,0.012064 ],
	[ 0.561438,0.046434 ],
	[ 0.476851,0.042381 ],
	[ 0.794023,0.030281 ],
	[ 0.795159,0.202232 ],
	[ 0.475907,0.153751 ],
	[ 0.385924,0.236421 ],
	[ 0.448342,0.23598 ],
	[ 0.436488,0.202691 ],
	[ 0.386857,0.202506 ],
	[ 0.590134,0.153861 ],
	[ 0.574769,0.124782 ],
	[ 0.436488,0.202691 ],
	[ 0.574769,0.124782 ],
	[ 0.385924,0.236421 ],
	[ 0.386857,0.202506 ],
	[ 0.475907,0.153751 ],
	[ 0.594539,0.114792 ],
	[ 0.015138,0.114792 ],
	[ 0.43537,0.201294 ],
	[ 0.015138,0.131074 ],
	[ 0.015138,0.114792 ],
	[ 0.594539,0.114792 ],
	[ 0.015138,0.131074 ],
	[ 0.43537,0.201294 ],
	[ 0.734673,0.874576 ],
	[ 0.734673,0.97538 ],
	[ 0.489894,0.857747 ],
	[ 0.489894,0.742834 ],
	[ 0.268166,0.742834 ],
	[ 0.268166,0.857747 ],
	[ 0.023386,0.975379 ],
	[ 0.023386,0.874576 ],
	[ 0.730021,0.874576 ],
	[ 0.489894,0.742834 ],
	[ 0.489894,0.900088 ],
	[ 0.730021,0.97538 ],
	[ 0.268166,0.742834 ],
	[ 0.268166,0.900087 ],
	[ 0.024225,0.874576 ],
	[ 0.024225,0.975379 ],
	[ 0.320565,0.789066 ],
	[ 0.437495,0.789066 ],
	[ 0.437495,0.887598 ],
	[ 0.320565,0.887598 ],
	[ 0.320565,0.789066 ],
	[ 0.320565,0.901125 ],
	[ 0.437495,0.901125 ],
	[ 0.437495,0.789066 ],
	[ 0.520182,0.71326 ],
	[ 0.520182,0.996213 ],
	[ 0.488895,0.996213 ],
	[ 0.488895,0.71326 ],
	[ 0.520182,0.995206 ],
	[ 0.520182,0.714096 ],
	[ 0.488895,0.714096 ],
	[ 0.488895,0.995206 ],
	[ 0.450393,0.633508 ],
	[ 0.450393,0.688829 ],
	[ 0.305407,0.688829 ],
	[ 0.305407,0.633508 ],
	[ 0.479151,0.814499 ],
	[ 0.276649,0.814499 ],
	[ 0.265367,0.71326 ],
	[ 0.265367,0.996213 ],
	[ 0.23408,0.996213 ],
	[ 0.23408,0.71326 ],
	[ 0.265367,0.995206 ],
	[ 0.265367,0.714096 ],
	[ 0.23408,0.714096 ],
	[ 0.23408,0.995206 ],
	[ 0.028721,0.94266 ],
	[ 0.040147,0.574073 ],
	[ 0.028721,0.574073 ],
	[ 0.028721,0.94266 ],
	[ 0.040147,0.94266 ],
	[ 0.040147,0.94266 ],
	[ 0.040147,0.94266 ],
	[ 0.028721,0.574073 ],
	[ 0.036339,0.574073 ],
	[ 0.715105,0.94266 ],
	[ 0.726532,0.574073 ],
	[ 0.715106,0.574073 ],
	[ 0.715105,0.94266 ],
	[ 0.726532,0.94266 ],
	[ 0.726532,0.574073 ],
	[ 0.726532,0.94266 ],
	[ 0.726532,0.94266 ],
	[ 0.715106,0.574073 ],
	[ 0.722723,0.574073 ],
	[ 0.285129,0.527934 ],
	[ 0.296555,0.248643 ],
	[ 0.285129,0.248643 ],
	[ 0.285129,0.527934 ],
	[ 0.296555,0.527934 ],
	[ 0.296555,0.248643 ],
	[ 0.296555,0.527934 ],
	[ 0.285129,0.248643 ],
	[ 0.292746,0.248643 ],
	[ 0.462826,0.527934 ],
	[ 0.474253,0.248643 ],
	[ 0.462826,0.248643 ],
	[ 0.462826,0.527934 ],
	[ 0.474252,0.527934 ],
	[ 0.474253,0.248643 ],
	[ 0.474252,0.527934 ],
	[ 0.470444,0.248643 ],
	[ 0.206191,0.012792 ],
	[ 0.320585,0.017893 ],
	[ 0.600932,1.34113 ],
	[ 0.38366,1.34113 ],
	[ 0.340565,0.928481 ],
	[ 0.644027,0.928482 ],
	[ 0.340565,0.94118 ],
	[ 0.644027,0.941181 ],
	[ 0.644027,0.928482 ],
	[ 0.340565,0.928481 ],
	[ 0.5,1.0 ],
	[ 0.083333,1.0 ],
	[ -0.25,1.0 ],
	[ 0.416667,1.0 ],
	[ 0.75,1.0 ],
	[ 0.083333,1.0 ],
	[ 0.206191,0.012792 ],
	[ 0.206191,0.012792 ],
	[ 0.326575,0.013401 ],
	[ 0.326575,0.013401 ],
	[ 0.258937,0.818404 ],
	[ 0.499123,0.818404 ],
	[ 0.450942,0.677332 ],
	[ 0.307118,0.677332 ],
	[ 0.307118,0.304879 ],
	[ 0.450942,0.30488 ],
	[ 0.450393,0.634335 ],
	[ 0.305407,0.634334 ],
	[ 0.305407,0.678323 ],
	[ 0.450393,0.678323 ],
	[ 0.499123,0.818404 ],
	[ 0.258937,0.818404 ],
	[ 0.450942,0.677332 ],
	[ 0.307118,0.677332 ]
); #end textures
our @vertices = (
	[ -2.87744,-2.03548,-1.00507 ],
	[ -2.87744,-2.84922,-1.00507 ],
	[ -2.87744,-2.03548,-1.00507 ],
	[ -2.87066,-2.84922,-0.714153 ],
	[ -2.87066,-2.03548,-0.714153 ],
	[ -2.83428,-2.58509,-0.785277 ],
	[ -2.83428,0.39035,-0.785276 ],
	[ -2.77265,-2.58509,-0.785277 ],
	[ -2.77265,0.39035,-0.785276 ],
	[ -2.74183,0.39035,-0.838649 ],
	[ -2.74183,0.39035,-0.731902 ],
	[ -2.74183,-2.58509,-0.838651 ],
	[ -2.74183,-2.58509,-0.731903 ],
	[ -1.17276,-3.0174,-0.550194 ],
	[ -1.17276,-3.00927,0.716256 ],
	[ -1.17276,-0.733242,-0.193126 ],
	[ -1.17276,-0.739993,0.627137 ],
	[ -0.971649,-1.58202,0.091718 ],
	[ -0.971649,-1.58202,0.093816 ],
	[ -0.971648,-1.58202,0.091718 ],
	[ -0.971648,-1.58202,0.093816 ],
	[ -0.919622,-3.0174,-0.550194 ],
	[ -0.919622,-3.00927,0.716256 ],
	[ -0.919621,-0.733242,-0.193126 ],
	[ -0.919621,-3.00927,0.716256 ],
	[ -0.919621,-0.739993,0.627137 ],
	[ -0.896981,-2.24142,0.608647 ],
	[ -0.896981,-1.89962,-0.26927 ],
	[ -0.896981,-0.971983,0.301365 ],
	[ -0.896981,-0.971983,0.608647 ],
	[ -0.828346,-1.55051,-0.193933 ],
	[ -0.828346,-1.44057,0.020239 ],
	[ -0.828345,-1.55051,-0.193933 ],
	[ -0.828345,-1.44057,0.020239 ],
	[ -0.759736,3.0174,0.089051 ],
	[ -0.759736,0.762811,0.08905 ],
	[ -0.698106,3.0174,0.089051 ],
	[ -0.698105,0.762811,0.08905 ],
	[ -0.66729,3.0174,0.035678 ],
	[ -0.66729,3.0174,0.142425 ],
	[ -0.66729,0.762811,0.035677 ],
	[ -0.66729,0.762811,0.142424 ],
	[ -0.595673,-0.451212,-0.553575 ],
	[ -0.595673,-0.536022,-0.798754 ],
	[ -0.595673,-0.089443,-0.802003 ],
	[ -0.595673,-0.096115,-0.552213 ],
	[ -0.581825,-0.443211,-0.543283 ],
	[ -0.581825,-0.443211,0.728817 ],
	[ -0.581825,2.56343,0.091717 ],
	[ -0.581825,2.56343,0.093815 ],
	[ -0.581825,2.56343,-0.026101 ],
	[ -0.581825,2.56343,0.211633 ],
	[ -0.473029,-2.1406,0.597286 ],
	[ -0.473029,-2.2498,1.00507 ],
	[ -0.473029,-1.34519,0.850424 ],
	[ -0.473029,-1.34519,0.597286 ],
	[ 0.473028,-2.2498,1.00507 ],
	[ 0.473028,-2.1406,0.597286 ],
	[ 0.473028,-1.34519,0.850424 ],
	[ 0.473028,-1.34519,0.597286 ],
	[ 0.577384,-0.451212,-0.553575 ],
	[ 0.577384,-0.096115,-0.552212 ],
	[ 0.577384,-0.089443,-0.802003 ],
	[ 0.577384,-0.536022,-0.798754 ],
	[ 0.581825,-0.443212,-0.543283 ],
	[ 0.581825,-0.443211,0.728816 ],
	[ 0.581826,2.56343,-0.026101 ],
	[ 0.581826,2.56343,0.091717 ],
	[ 0.581826,2.56343,0.093815 ],
	[ 0.581826,2.56343,0.211632 ],
	[ 0.67798,3.0174,0.089051 ],
	[ 0.67798,0.762811,0.08905 ],
	[ 0.73961,3.0174,0.089051 ],
	[ 0.739611,0.762811,0.08905 ],
	[ 0.770426,3.0174,0.035678 ],
	[ 0.770426,3.0174,0.142425 ],
	[ 0.770426,0.762811,0.035677 ],
	[ 0.770426,0.762811,0.142424 ],
	[ 0.810057,-1.55051,-0.193933 ],
	[ 0.810057,-1.44057,0.020239 ],
	[ 0.888894,-3.0174,-0.550194 ],
	[ 0.888894,-3.00927,0.716256 ],
	[ 0.888894,-0.733242,-0.193126 ],
	[ 0.888894,-0.739993,0.627137 ],
	[ 0.89698,-2.24142,0.608647 ],
	[ 0.89698,-1.89963,-0.26927 ],
	[ 0.89698,-0.971984,0.301365 ],
	[ 0.89698,-0.971984,0.608647 ],
	[ 0.971647,-1.58202,0.091718 ],
	[ 0.971647,-1.58202,0.093816 ],
	[ 1.14203,-3.0174,-0.550194 ],
	[ 1.14203,-3.00927,0.716256 ],
	[ 1.14203,-0.733242,-0.193126 ],
	[ 1.14203,-0.739993,0.627137 ],
	[ 2.71912,0.39035,-0.785276 ],
	[ 2.71912,-2.58509,-0.785277 ],
	[ 2.78075,-2.58509,-0.785277 ],
	[ 2.78075,0.39035,-0.785276 ],
	[ 2.81157,-2.58509,-0.838651 ],
	[ 2.81157,0.39035,-0.838649 ],
	[ 2.81157,-2.58509,-0.731903 ],
	[ 2.81157,0.39035,-0.731902 ],
	[ 2.8398,-2.84922,-0.714153 ],
	[ 2.8398,-2.03548,-0.714153 ],
	[ 2.8398,-2.84922,-0.714153 ],
	[ 2.87744,-2.84922,-1.00507 ],
	[ 2.87744,-2.03548,-1.00507 ]
); #end vertices
1;
