--[[ 
  This solver is based on the code from 'Real-time Fluid Dynamics for Games' by Jos Stam.
  http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
]]
local solver = {}
local N = 64
local N1, N2 = N + 1, N + 2

setfenv(1,solver)

function add_source(N, x, s, dt)
	local i, size = 0,(N2)*(N2)
	for i=1,size do
		x[i] = x[i] + dt * s[i]
	end
end

function set_bnd(N, b, x)
	local N2N, N2N1,i = N2*N, N2*N1

	for i=1,N do
		local N2i = N2*i
		local _0i,_1i,_Ni,_N1i = N2i,1+N2i,N+N2i,N1+N2i
		local _i0,_i1,_iN,_iN1 = i,i+N2,i+N2N,i+(N2N1)

		local sign = 1
		if b == 1 then sign = -1 end
		x[_0i]	= x[_1i] * sign
		x[_N1i]	= x[_Ni] * sign

		sign = 1 
		if b == 2 then sign = -1 end
		x[_i0]	= x[_i1] * sign
		x[_iN1]	= x[_iN] * sign
	end

	x[0]		= 0.5 * ( x[1]		+ x[N2]		)
	x[N2N1] 	= 0.5 * ( x[1+N2N1] + x[N2N]	)
	x[N1]		= 0.5 * ( x[N]		+ x[N1+N2]	)
	x[N1+N2N1]	= 0.5 * ( x[N+N2N1] + x[N1+N2N]	)
end

function lin_solve(N, b, x, x0, a, c)
	local i, j, k

	for k=1,20 do
		for i = 1, N do
			for j=1,N do 
				x[i+N2*j] = ( x0[i+N2*j] + a * (x[(i-1)+N2*j] + x[(i+1)+N2*j]+x[i+N2*(j-1)] + x[i+N2*(j+1)]) ) / c;
			end 
		end
		set_bnd ( N, b, x )
	end
end

function diffuse( N, b, x, x0, diff, dt )
	local a = dt*diff*N*N
	lin_solve( N, b, x, x0, a, 1+4*a )
end

function advect (N, b, d, d0, u, v, dt )
	local i, j, i0, j0, i1, j1;
	local x, y, s0, t0, s1, t1, dt0;

	dt0 = dt*N;
	for i = 1, N  do 
		for j = 1, N do 
			x = i-dt0*u[i+N2*j]; 
			y = j-dt0*v[i+N2*j];

			if x < 0.5 then 
				x = 0.5
			end
			
			if x > N+0.5 then
				x = N+0.5
			end
			
			i0 = x - x%1
			i1 = i0+1;
			
			if y < 0.5 then
				y = 0.5
			end

			if y > N+0.5 then
				y = N+0.5 
			end
			
			j0 = y - y%1 
			j1 = j0+1
			s1 = x-i0
			s0 = 1-s1 
			t1 = y-j0 
			t0 = 1-t1
			d[i+N2*j] = s0 * ( t0 * d0[i0+N2*j0] + t1 * d0[i0+N2*j1] ) 
					  + s1 * ( t0 * d0[i1+N2*j0] + t1 * d0[i1+N2*j1] )
		end 
	end
	set_bnd ( N, b, d )
end

function project(N, u, v, p, div)
	local i, j

	for i = 1, N do 
		for j=1,N do 
			div[i+N2*j] = -0.5*(u[(i+1)+N2*j]-u[(i-1)+N2*j]+v[i+N2*(j+1)]-v[i+N2*(j-1)])/N;
			p[i+N2*j] = 0;
		end
	end	
	set_bnd ( N, 0, div );
	set_bnd ( N, 0, p );

	lin_solve ( N, 0, p, div, 1, 4 );

	for i = 1, N do 
		for j=1,N do 
			local index = i+N2*j
			u[index] = u[index] - 0.5*N*(p[(i+1)+N2*j]-p[(i-1)+N2*j]);
			v[index] = v[index] - 0.5*N*(p[i+N2*(j+1)]-p[i+N2*(j-1)]);
		end
	end
	set_bnd ( N, 1, u );
	set_bnd ( N, 2, v );
end

function dens_step ( N, x, x0, u, v, diff, dt )
	add_source ( N, x, x0, dt );
	x0,x = x,x0
	diffuse ( N, 0, x, x0, diff, dt );
	
	x0,x = x,x0
	advect ( N, 0, x, x0, u, v, dt );
end

function vel_step ( N, u, v, u0, v0, visc, dt )
	add_source ( N, u, u0, dt );
	add_source ( N, v, v0, dt );

	u0,u = u,u0
	diffuse ( N, 1, u, u0, visc, dt );
	
	v0,v = v,v0
	diffuse ( N, 2, v, v0, visc, dt );
	
	project ( N, u, v, u0, v0 );
	u0,u = u,u0
	v0,v = v,v0
	advect ( N, 1, u, u0, u0, v0, dt ); 
	advect ( N, 2, v, v0, u0, v0, dt );
	project ( N, u, v, u0, v0 );
end

function init(size)
	N = size
	N1, N2 = N + 1, N + 2
end

return solver
