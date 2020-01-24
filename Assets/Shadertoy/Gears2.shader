
    Shader "ShaderMan/Gears2"
	{
	Properties{
	    bg_color ("Background Color", Color) = (0,0,0,0)
	}
	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
	Pass
	{
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"
			
    fixed4 bg_color;

    float4 vec4(float x,float y,float z,float w){return float4(x,y,z,w);}
    float4 vec4(float x){return float4(x,x,x,x);}
    float4 vec4(float2 x,float2 y){return float4(float2(x.x,x.y),float2(y.x,y.y));}
    float4 vec4(float3 x,float y){return float4(float3(x.x,x.y,x.z),y);}


    float3 vec3(float x,float y,float z){return float3(x,y,z);}
    float3 vec3(float x){return float3(x,x,x);}
    float3 vec3(float2 x,float y){return float3(float2(x.x,x.y),y);}

    float2 vec2(float x,float y){return float2(x,y);}
    float2 vec2(float x){return float2(x,x);}

    float vec(float x){return float(x);}
    
    

	struct VertexInput {
    float4 vertex : POSITION;
	float2 uv:TEXCOORD0;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
	//VertexInput
	};
	struct VertexOutput {
	float4 pos : SV_POSITION;
	float2 uv:TEXCOORD0;
	//VertexOutput
	};
	
	
	VertexOutput vert (VertexInput v)
	{
	VertexOutput o;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.uv;
	//VertexFactory
	return o;
	}
    
    // Inspired by:
//  http://cmdrkitten.tumblr.com/post/172173936860


#define Pi 3.14159265359

struct Gear
{
    float t;			// Time
    float gearR;		// Gear radius
    float teethH;		// Teeth height
    float teethR;		// Teeth "roundness"
    float teethCount;	// Teeth count
    float diskR;		// Inner or outer border radius
    float3 color;			// Color
};

    
    
float GearFunction(float2 uv, Gear g)
{
    float r = length(uv);
    float a = atan2( uv.x,uv.y);
    
    // Gear polar function:
    //  A sine squashed by a logistic function gives a convincing
    //  gear shape!
    float p = g.gearR-0.5*g.teethH + 
              g.teethH/(1.0+exp(g.teethR*sin(g.t + g.teethCount*a)));

    float gear = r - p;
    float disk = r - g.diskR;
    
    return g.gearR > g.diskR ? max(-disk, gear) : max(disk, -gear);
}


float GearDe(float2 uv, Gear g)
{
    // IQ's f/|Grad(f)| distance estimator:
    float f = GearFunction(uv, g);
    float2 eps = vec2(0.0001, 0);
    float2 grad = vec2(
        GearFunction(uv + eps.xy, g) - GearFunction(uv - eps.xy, g),
        GearFunction(uv + eps.yx, g) - GearFunction(uv - eps.yx, g)) / (2.0*eps.x);
    
    return (f)/length(grad);
}



float GearShadow(float2 uv, Gear g)
{
    float r = length(uv+vec2(0.1));
    float de = r - g.diskR + 0.0*(g.diskR - g.gearR);
    float eps = 0.4*g.diskR;
    return smoothstep(eps, 0., abs(de));
}


void DrawGear(inout float3 color, float2 uv, Gear g, float eps)
{
	float d = smoothstep(eps, -eps, GearDe(uv, g));
    float s = 1.0 - 0.7*GearShadow(uv, g);
    color = lerp(s*color, g.color, d);
}
    
	fixed4 frag(VertexOutput vertex_output) : SV_Target
	{
	
    float t = 0.5*_Time.y;
    float2 uv = 2.0*(vertex_output.uv - 0.5*1)/1;
    float eps = 2.0/1;

    // Scene parameters;
	float3 base = vec3(0.95, 0.7, 0.2);
	base.xyz = bg_color.xyz;
    float count = 8.0;

    // Gear outer = Gear(0.0, 0.8, 0.08, 4.0, 32.0, 0.9, base);
    // Gear inner = Gear(0.0, 0.4, 0.08, 4.0, 16.0, 0.3, base);
    
    /*
    struct Gear
{
    float t;			// Time
    float gearR;		// Gear radius
    float teethH;		// Teeth height
    float teethR;		// Teeth "roundness"
    float teethCount;	// Teeth count
    float diskR;		// Inner or outer border radius
    float3 color;			// Color
};
    */
    Gear outer;
    outer.t = 0.0;
    outer.gearR = 0.8;
    outer.teethH = 0.08;
    outer.teethR = 4.0;
    outer.teethCount = 32.0;
    outer.diskR = 0.9;
    outer.color = base;
    
    Gear inner;
    inner.t = 0.0;
    inner.gearR = 0.4;
    inner.teethH = 0.08;
    inner.teethR = 4.0;
    inner.teethCount = 16.0;
    inner.diskR = 0.3;
    inner.color = base;
    
    // Draw inner gears back to front:
    float3 color = vec3(0.0);
    [unroll(100)]
    
    for(float i=0.0; i<count; i++)
    {
        t += 2.0*Pi/count;
 	    inner.t = 16.0*t;
        inner.color = base*(0.35 + 0.6*i/(count-1.0));
        DrawGear(color, uv+0.4*vec2(cos(t),sin(t)), inner, eps);
    }
    
    // Draw outer gear:
    DrawGear(color, uv, outer, eps);
    
    return vec4(color,1.0);

	}
	ENDCG
	}
  }
  }
