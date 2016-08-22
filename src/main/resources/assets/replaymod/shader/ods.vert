#version 110

varying vec4 vertColor;
varying float vertId;

varying vec4 textureCoord;
varying vec4 lightMapCoord;

uniform bool leftEye;
uniform int direction;

const float eyeDistance = 0.14;

void main() {
    // Transform to view space
    vec4 position = gl_ModelViewMatrix * gl_Vertex;

    // Distort for ODS
    //  O := The origin
    //  P := The current vertex/point
    //  T := Point of tangency with the tangent going through P
    // Distance between P and O
    float distPO = sqrt(position.x * position.x + position.z * position.z);
    float distTO = eyeDistance * 0.5;
    // Angle between PO and PT
    float angP = acos(distTO / distPO);
    // Angle between PO and TO (angle at the origin)
    float angO = 90.0 - angP;
    if (!leftEye) {
        angO = -angO;
    }
    // The angel of OP within the circle, that is between OP and O(0,1)
    float angOP = atan(position.x, position.z);
    // The angle of OT within the circle, that is between OT and O(0,1)
    float angOT = angO + angOP;
    // Calculate the vector between O and T and finally move the vertex by that vector
    position -= vec4(distTO * sin(angOT), 0, distTO * cos(angOT), 0);

    // Rotate for different cubic views
    float z;
    switch (direction) {
        case 0: // LEFT
            z = position.z;
            position.z = position.x;
            position.x = -z;
            break;
        case 1: // RIGHT
            z = position.z;
            position.z = -position.x;
            position.x = z;
            break;
        case 2: // FRONT
            // No changes required
            break;
        case 3: // BACK
            position.x = -position.x;
            position.z = -position.z;
            break;
        case 4: // TOP
            z = position.z;
            position.z = -position.y;
            position.y = z;
            break;
        case 5: // BOTTOM
            z = position.z;
            position.z = position.y;
            position.y = -z;
            break;
    }

    // Transform to screen space
	gl_Position = gl_ProjectionMatrix * position;

    // Misc.
	textureCoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	lightMapCoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    vertColor = gl_Color;
	gl_FogFragCoord = sqrt(position.x * position.x + position.y * position.y + position.z * position.z);
}