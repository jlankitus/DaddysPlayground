
    Shader "ShaderMan/Bubbles"
	{
	Properties
	{
	    _BackgroundColor ("BackgroundColor", Color) = (0,0,0,0)
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
    
    // Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
    
	fixed4 frag(VertexOutput vertex_output) : SV_Target
	{
	
	float2 uv = -1.0 + 2.0*vertex_output.uv / 1;
	uv.x *=  1 / 1;

    // background	 
	float3 color = vec3(0.8 + 0.2*uv.y);

    // bubbles	
	[unroll(100)]
for( int i=0; i<40; i++ )
	{
        // bubble seeds
		float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
		float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
		float pox =      sin(float(i)*321.55+4.1) * 1 / 1;

        // buble size, position and color
		float rad = 0.1 + 0.5*siz;
		float2  pos = vec2( pox, -1.0-rad + (2.0+2.0*rad)*fmod(pha+0.1*_Time.y*(0.2+0.8*siz),1.0));
		float dis = length( uv - pos );
		float3  col = lerp( vec3(0.94,0.3,0.0), vec3(0.1,0.4,0.8), 0.5+0.5*sin(float(i)*1.2+1.9));
		//    col+= 8.0*smoothstep( rad*0.95, rad, dis );
		
        // render
		float f = length(uv-pos)/rad;
		f = sqrt(clamp(1.0-f*f,0.0,1.0));
		color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
	}

    // vigneting	
	color *= sqrt(1.5-0.5*length(uv));

	return vec4(color,1.0);

	}
	ENDCG
	}
  }
  }
