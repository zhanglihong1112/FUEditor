varying vec3 N_frag,dPds_frag,dPdt_frag;
varying vec2 st_frag;
varying vec3 V_frag;

vec3 QuatTransformVector(vec4 Q,vec3 v){
	return v + 2.0*cross(Q.xyz, cross(Q.xyz,v) + Q.w*v);
}

vec4 quaterionSlerp(vec4 p, vec4 q, float t){
	if(abs(p[0]-q[0])<0.00001 && abs(p[1]-q[1])<0.00001 && abs(p[2]-q[2])<0.00001 && abs(p[3]-q[3])<0.00001)return p;
	float theta = acos(dot(p,q));
	float ws = sin(theta);
	float w1 = sin((1.0 - t)*theta)/ws;
	float w2 = sin(t*theta)/ws;
	return normalize(w1*p + w2*q);
}

void main(){
	
	vec3 Ps=P*scales;
	
	if(isFlipH>0.5){
		Ps.x = -Ps.x;
	}

	Ps = scale_e * Ps;

	//model transform
	Ps = (model_mat*vec4(Ps,1.0)).xyz; 
	Ps.z=-Ps.z;

	//weight transform
	if(0.5<obj_type&&obj_type<=0.75){
		vec4 head_quat;
		vec4 idq = vec4(0.0,0.0,0.0,1.0);
		
		head_quat = quaterionSlerp(idq,quatR1,1.0-weight);
		
		Ps -= weightOffset;
		Ps = QuatTransformVector(head_quat,Ps);
		Ps += weightOffset;

		vec4 Pf = vec4(Ps,1.0);
		gl_Position=mat_proj*(mat_cam*Pf);
	}else {
		vec4 Pf = vec4(Ps,1.0);
		gl_Position=mat_proj*(mat_view*Pf);
	}
	
	vec4 Pf = vec4(Ps,1.0);
	V_frag=normalize((mat_view*Pf).xyz);

	vec4 Nf=model_normal_mat*vec4(N.xyz,0.0);

	N_frag=normalize((mat_view_normal*vec4(Nf.x,Nf.y,-Nf.z,0.0)).xyz);
	dPds_frag=normalize((mat_view_normal*vec4(dPds.x,dPds.y,-dPds.z,0.0)).xyz);
	dPdt_frag=normalize((mat_view_normal*vec4(dPdt.x,dPdt.y,-dPdt.z,0.0)).xyz);

	st_frag=st;
	st_frag.y = 1.0 - st_frag.y;
	st_frag=lbrt.xy + (lbrt.zw-lbrt.xy)*st_frag;
	st_frag.y = 1.0 - st_frag.y;
}
