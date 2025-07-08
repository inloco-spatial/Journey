static const float kPI2 = radians(360);

float mod(float a, float b)
{
	return frac(a / b) * b;
}

float2 mod(float2 a, float2 b)
{
	return frac(a / b) * b;
}

float3 mod(float3 a, float3 b)
{
	return frac(a / b) * b;
}

float4 mod(float4 a, float4 b)
{
	return frac(a / b) * b;
}

float2x2 Rotation2D(float angle)
{
	float c, s;
	sincos(angle, s, c);
	return float2x2(c, s, -s, c);
}

// The MIT License
// Copyright © 2019 Alin Loghin
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// hashes

uint ihash1D(uint q)
{
	// hash by Hugo Elias, Integer Hash - I, 2017
	q = (q << 13u) ^ q;
	return q * (q * q * 15731u + 789221u) + 1376312589u;
}

uint4 ihash1D(uint4 q)
{
	// hash by Hugo Elias, Integer Hash - I, 2017
	q = (q << 13u) ^ q;
	return q * (q * q * 15731u + 789221u) + 1376312589u;
}

float hash1D(float2 x)
{
	// hash by Inigo Quilez, Integer Hash - III, 2017
	uint2 q = uint2(x * 65536.0);
	q = 1103515245u * ((q >> 1u) ^ q.yx);
	uint n = 1103515245u * (q.x ^ (q.y >> 3u));
	return float(n) * (1.0 / float(0xffffffffu));
}

float2 hash2D(float2 x)
{
	// based on: Inigo Quilez, Integer Hash - III, 2017
	uint4 q = uint2(x * 65536.0).xyyx + uint2(0u, 3115245u).xxyy;
	q = 1103515245u * ((q >> 1u) ^ q.yxwz);
	uint2 n = 1103515245u * (q.xz ^ (q.yw >> 3u));
	return float2(n) * (1.0 / float(0xffffffffu));
}

float3 hash3D(float2 x) 
{
	// based on: pcg3 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
	uint3 v = uint3(x.xyx * 65536.0) * 1664525u + 1013904223u;
	v += v.yzx * v.zxy;
	v ^= v >> 16u;

	v.x += v.y * v.z;
	v.y += v.z * v.x;
	v.z += v.x * v.y;
	return float3(v) * (1.0 / float(0xffffffffu));
}

float4 hash4D(float2 x)
{
	// based on: pcg4 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
	uint4 v = uint4(x.xyyx * 65536.0) * 1664525u + 1013904223u;

	v += v.yzxy * v.wxyz;
	v.x += v.y * v.w;
	v.y += v.z * v.x;
	v.z += v.x * v.y;
	v.w += v.y * v.z;
	
	v.x += v.y * v.w;
	v.w += v.y * v.z;
	
	v ^= v >> 16u;

	return float4(v ^ (v >> 16u)) * (1.0 / float(0xffffffffu));
}

float4 hash4D(float4 x)
{
	// based on: pcg4 by Mark Jarzynski: http://www.jcgt.org/published/0009/03/02/
	uint4 v = uint4(x * 65536.0) * 1664525u + 1013904223u;

	v += v.yzxy * v.wxyz;
	v.x += v.y * v.w;
	v.y += v.z * v.x;
	v.z += v.x * v.y;
	v.w += v.y * v.z;
	
	v.x += v.y*v.w;
	v.y += v.z*v.x;
	v.z += v.x*v.y;
	v.w += v.y*v.z;

	v ^= v >> 16u;

	return float4(v ^ (v >> 16u)) * (1.0 / float(0xffffffffu));
}


float2 betterHash2D(float2 x)
{
	uint2 q = uint2(x);
	uint h0 = ihash1D(ihash1D(q.x) + q.y);
	uint h1 = h0 * 1933247u + ~h0 ^ 230123u;
	return float2(h0, h1)  * (1.0 / float(0xffffffffu));
}

// generates a random number for each of the 4 cell corners
float4 betterHash2D(float4 cell)    
{
	uint4 i = uint4(cell) + 101323u;
	uint4 hash = ihash1D(ihash1D(i.xzxz) + i.yyww);
	return float4(hash) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the 4 cell corners
void betterHash2D(float4 cell, out float4 hashX, out float4 hashY)
{
	uint4 i = uint4(cell) + 101323u;
	uint4 hash0 = ihash1D(ihash1D(i.xzxz) + i.yyww);
	uint4 hash1 = ihash1D(hash0 ^ 1933247u);
	hashX = float4(hash0) * (1.0 / float(0xffffffffu));
	hashY = float4(hash1) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the four 2D coordinates
void betterHash2D(float4 coords0, float4 coords1, out float4 hashX, out float4 hashY)
{
	uint4 hash0 = ihash1D(ihash1D(uint4(coords0.xz, coords1.xz)) + uint4(coords0.yw, coords1.yw));
	uint4 hash1 = hash0 * 1933247u + ~hash0 ^ 230123u;
	hashX = float4(hash0) * (1.0 / float(0xffffffffu));
	hashY = float4(hash1) * (1.0 / float(0xffffffffu));
} 

// generates a random number for each of the 8 cell corners
void betterHash3D(float3 cell, float3 cellPlusOne, out float4 lowHash, out float4 highHash)
{
	uint4 cells = uint4(cell.xy, cellPlusOne.xy);  
	uint4 hash = ihash1D(ihash1D(cells.xzxz) + cells.yyww);
	
	lowHash = float4(ihash1D(hash + uint(cell.z))) * (1.0 / float(0xffffffffu));
	highHash = float4(ihash1D(hash + uint(cellPlusOne.z))) * (1.0 / float(0xffffffffu));
}

#define multiHash2D betterHash2D
#define multiHash3D betterHash3D

void smultiHash2D(float4 cell, out float4 hashX, out float4 hashY)
{
	multiHash2D(cell, hashX, hashY);
	hashX = hashX * 2.0 - 1.0; 
	hashY = hashY * 2.0 - 1.0;
}

// common

float2 noiseInterpolate(const in float2 x) 
{ 
	float2 x2 = x * x;
	return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
float4 noiseInterpolate(const in float4 x) 
{ 
	float4 x2 = x * x;
	return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
float4 noiseInterpolateDu(const in float2 x) 
{ 
	float2 x2 = x * x;
	float2 u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
	float2 du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
	return float4(u, du);
}
void noiseInterpolateDu(const in float3 x, out float3 u, out float3 du) 
{ 
	float3 x2 = x * x;
	u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
	du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
}

float distanceMetric(float2 pos, uint metric)
{
	switch (metric)
	{
		case 0u:
			// squared euclidean
			return dot(pos, pos);
		case 1u:
			// manhattam   
			return dot(abs(pos), 1.0);
		case 2u:
			// chebyshev
			return max(abs(pos.x), abs(pos.y));
		default:
			// triangular
			return  max(abs(pos.x) * 0.866025 + pos.y * 0.5, -pos.y);
	}
}

float4 distanceMetric(float4 px, float4 py, uint metric)
{
	switch (metric)
	{
		case 0u:
			// squared euclidean
			return px * px + py * py;
		case 1u:
			// manhattam   
			return abs(px) + abs(py);
		case 2u:
			// chebyshev
			return max(abs(px), abs(py));
		default:
			// triangular
			return max(abs(px) * 0.866025 + py * 0.5, -py);
	}
}

// noises

float noise(float2 pos, float2 scale, float phase, float seed) 
{
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float2 f = pos - i.xy;
	i = mod(i, scale.xyxy) + seed;

	float4 hash = multiHash2D(i);
	hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;
	float a = hash.x;
	float b = hash.y;
	float c = hash.z;
	float d = hash.w;

	float2 u = noiseInterpolate(f);
	float value = lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
	return value * 2.0 - 1.0;
}

float3 noised(float2 pos, float2 scale, float phase, float seed) 
{
	// value noise with derivatives based on Inigo Quilez
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float2 f = pos - i.xy;
	i = mod(i, scale.xyxy) + seed;

	float4 hash = multiHash2D(i);
	hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;
	float a = hash.x;
	float b = hash.y;
	float c = hash.z;
	float d = hash.w;
	
	float4 udu = noiseInterpolateDu(f);    
	float abcd = a - b - c + d;
	float value = a + (b - a) * udu.x + (c - a) * udu.y + abcd * udu.x * udu.y;
	float2 derivative = udu.zw * (udu.yx * abcd + float2(b, c) - a);
	return float3(value * 2.0 - 1.0, derivative);
}

float2 multiNoise(float4 pos, float4 scale, float phase, float2 seed) 
{
	pos *= scale;
	float4 i = floor(pos);
	float4 f = pos - i;
	float4 i0 = mod(i.xyxy + float2(0.0, 1.0).xxyy, scale.xyxy) + seed.x;
	float4 i1 = mod(i.zwzw + float2(0.0, 1.0).xxyy, scale.xyxy) + seed.y;

	float4 hash0 = multiHash2D(i0);
	hash0 = 0.5 * sin(phase + kPI2 * hash0) + 0.5;
	float4 hash1 = multiHash2D(i1);
	hash1 = 0.5 * sin(phase + kPI2 * hash1) + 0.5;
	float2 a = float2(hash0.x, hash1.x);
	float2 b = float2(hash0.y, hash1.y);
	float2 c = float2(hash0.z, hash1.z);
	float2 d = float2(hash0.w, hash1.w);

	float4 u = noiseInterpolate(f);
	float2 value = lerp(a, b, u.xz) + (c - a) * u.yw * (1.0 - u.xz) + (d - b) * u.xz * u.yw;
	return value * 2.0 - 1.0;
}

float3 gradientNoised(float2 pos, float2 scale, float seed) 
{
	// gradient noise with derivatives based on Inigo Quilez
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;
	i = mod(i, scale.xyxy) + seed;
	
	float4 hashX, hashY;
	smultiHash2D(i, hashX, hashY);
	float2 a = float2(hashX.x, hashY.x);
	float2 b = float2(hashX.y, hashY.y);
	float2 c = float2(hashX.z, hashY.z);
	float2 d = float2(hashX.w, hashY.w);
	
	float4 gradients = hashX * f.xzxz + hashY * f.yyww;

	float4 udu = noiseInterpolateDu(f.xy);
	float2 u = udu.xy;
	float2 g = lerp(gradients.xz, gradients.yw, u.x);
	
	float2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
	dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);
	return float3(lerp(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
}
float3 gradientNoised(float2 pos, float2 scale, float2x2 transform, float seed) 
{
	// gradient noise with derivatives based on Inigo Quilez
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;
	i = mod(i, scale.xyxy) + seed;
	
	float4 hashX, hashY;
	smultiHash2D(i, hashX, hashY);

	// transform gradients
	float4 m = float4(transform);
	float4 rh = float4(hashX.x, hashY.x, hashX.y, hashY.y);
	rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
	hashX.xy = rh.xz;
	hashY.xy = rh.yw;

	rh = float4(hashX.z, hashY.z, hashX.w, hashY.w);
	rh = rh.xxzz * m.xyxy + rh.yyww * m.zwzw;
	hashX.zw = rh.xz;
	hashY.zw = rh.yw;
	
	float2 a = float2(hashX.x, hashY.x);
	float2 b = float2(hashX.y, hashY.y);
	float2 c = float2(hashX.z, hashY.z);
	float2 d = float2(hashX.w, hashY.w);
	
	float4 gradients = hashX * f.xzxz + hashY * f.yyww;

	float4 udu = noiseInterpolateDu(f.xy);
	float2 u = udu.xy;
	float2 g = lerp(gradients.xz, gradients.yw, u.x);
	
	float2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
	dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);
	return float3(lerp(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
}

float3 gradientNoised(float2 pos, float2 scale, float rotation, float seed) 
{
	return gradientNoised(pos, scale, Rotation2D(rotation), seed);
}

float perlinNoise(float2 pos, float2 scale, float seed)
{
	// based on Modifications to Classic Perlin Noise by Brian Sharpe: https://archive.is/cJtlS
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;
	i = mod(i, scale.xyxy) + seed;

	// grid gradients
	float4 gradientX, gradientY;
	multiHash2D(i, gradientX, gradientY);
	gradientX -= 0.49999;
	gradientY -= 0.49999;

	// perlin surflet
	float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) * (gradientX * f.xzxz + gradientY * f.yyww);
	// normalize: 1.0 / 0.75^3
	gradients *= 2.3703703703703703703703703703704;
	float4 lengthSq = f * f;
	lengthSq = lengthSq.xzxz + lengthSq.yyww;
	float4 xSq = 1.0 - min(1.0, lengthSq); 
	xSq = xSq * xSq * xSq;
	return dot(xSq, gradients);
}
float perlinNoise(float2 pos, float2 scale, float2x2 transform, float seed)
{
	// based on Modifications to Classic Perlin Noise by Brian Sharpe: https://archive.is/cJtlS
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;
	i = mod(i, scale.xyxy) + seed;

	// grid gradients
	float4 gradientX, gradientY;
	multiHash2D(i, gradientX, gradientY);
	gradientX -= 0.49999;
	gradientY -= 0.49999;

	// transform gradients
	float4 m = float4(transform);
	float4 rg = float4(gradientX.x, gradientY.x, gradientX.y, gradientY.y);
	rg = rg.xxzz * m.xyxy + rg.yyww * m.zwzw;
	gradientX.xy = rg.xz;
	gradientY.xy = rg.yw;

	rg = float4(gradientX.z, gradientY.z, gradientX.w, gradientY.w);
	rg = rg.xxzz * m.xyxy + rg.yyww * m.zwzw;
	gradientX.zw = rg.xz;
	gradientY.zw = rg.yw;

	// perlin surflet
	float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) * (gradientX * f.xzxz + gradientY * f.yyww);
	// normalize: 1.0 / 0.75^3
	gradients *= 2.3703703703703703703703703703704;
	f = f * f;
	f = f.xzxz + f.yyww;
	float4 xSq = 1.0 - min(1.0, f); 
	return dot(xSq * xSq * xSq, gradients);
}
float perlinNoise(float2 pos, float2 scale, float rotation, float seed) 
{
	return perlinNoise(pos, scale, Rotation2D(rotation), seed);
}

float3 perlinNoised(float2 pos, float2 scale, float2x2 transform, float seed)
{
	// based on Modifications to Classic Perlin Noise by Brian Sharpe: https://archive.is/cJtlS
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float4 f = (pos.xyxy - i.xyxy) - float2(0.0, 1.0).xxyy;
	i = mod(i, scale.xyxy) + seed;

	// grid gradients
	float4 gradientX, gradientY;
	multiHash2D(i, gradientX, gradientY);
	gradientX -= 0.49999;
	gradientY -= 0.49999;

	// transform gradients
	float4 mt = float4(transform);
	float4 rg = float4(gradientX.x, gradientY.x, gradientX.y, gradientY.y);
	rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
	gradientX.xy = rg.xz;
	gradientY.xy = rg.yw;

	rg = float4(gradientX.z, gradientY.z, gradientX.w, gradientY.w);
	rg = rg.xxzz * mt.xyxy + rg.yyww * mt.zwzw;
	gradientX.zw = rg.xz;
	gradientY.zw = rg.yw;
	
	// perlin surflet
	float4 gradients = rsqrt(gradientX * gradientX + gradientY * gradientY) * (gradientX * f.xzxz + gradientY * f.yyww);
	float4 m = f * f;
	m = m.xzxz + m.yyww;
	m = max(1.0 - m, 0.0);
	float4 m2 = m * m;
	float4 m3 = m * m2;
	// compute the derivatives
	float4 m2Gradients = -6.0 * m2 * gradients;
	float2 grad = float2(dot(m2Gradients, f.xzxz), dot(m2Gradients, f.yyww)) + float2(dot(m3, gradientX), dot(m3, gradientY));
	// sum the surflets and normalize: 1.0 / 0.75^3
	return float3(dot(m3, gradients), grad) * 2.3703703703703703703703703703704;
}

float3 perlinNoised(float2 pos, float2 scale, float rotation, float seed) 
{
	return perlinNoised(pos, scale, Rotation2D(rotation), seed);
}

float organicNoise(float2 pos, float2 scale, float density, float2 phase, float contrast, float highlights, float shift, float seed)
{
	float2 s = lerp(1.0, scale - 1.0, density);
	float nx = perlinNoise(pos + phase, scale, seed);
	float ny = perlinNoise(pos, s, seed);

	float n = length(float2(nx, ny) * lerp(float2(2.0, 0.0), float2(0.0, 2.0), shift));
	n = pow(n, 1.0 + 8.0 * contrast) + (0.15 * highlights) / n;
	return n * 0.5;
}

float2 randomLines(float2 pos, float2 scale, float count, float width, float jitter, float2 smoothness, float phase, float seed)
{
	float strength = jitter * 1.25;

	// compute gradient
	// TODO: compute the gradient analytically
	float2 grad;
	float3 offsets = float3(1.0, 0.0, -1.0) / 1024.0;
	float4 p = pos.xyxy + offsets.xyzy;
	float2 nv = count * (strength * multiNoise(p, scale.xyxy, phase, seed) + p.yw);
	grad.x = nv.x - nv.y;
	p = pos.xyxy + offsets.yxyz;
	nv = count * (strength * multiNoise(p, scale.xyxy, phase, seed) + p.yw);
	grad.y = nv.x - nv.y;
	
	float v =  count * (strength * noise(pos, scale, phase, seed) + pos.y);
	float w = frac(v) / length(grad / (2.0 * offsets.x));
	width *= 0.1;
	smoothness *= width;
	smoothness += max(abs(grad.x), abs(grad.y)) * 0.02;
	
	float d = smoothstep(0.0, smoothness.x, w) - smoothstep(max(width - smoothness.y, 0.0), width, w);
	return float2(d, mod(floor(v), count));
}
float4 randomLines(float2 pos, float2 scale, float count, float width, float jitter, float2 smoothness, float phase, float colorVariation, float seed)
{
	float2 l = randomLines(pos, scale, count, width, jitter, smoothness, phase, seed);
	float3 r = hash3D(l.yy + seed);
	return float4(l.x * (r.x < colorVariation ? r : r.xxx), l.x);
}

float4 fbmMulti(float2 pos, float2 scale, float lacunarity, int octaves, float phase, float seed) 
{    
	float4 seeds = float4(0.0, 1031.0, 537.0, 23.0) + seed;
	float f = 2.0 / lacunarity;
	
	float4 value = 0.0;
	float w = 1.0;
	float acc = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float2 ns = float2(scale / w);
		float4 n;
		n.xy = multiNoise(pos.xyxy, ns.xyxy, phase, seeds.xy);
		n.zw = multiNoise(pos.xyxy, ns.xyxy, phase, seeds.zw);
		value += (n * 0.5 + 0.5) * w;
		acc += w;
		w *= 0.5 * f;
	}
	return value / acc;
}

float3 dotsNoise(float2 pos, float2 scale, float density, float size, float sizeVariation, float roundness, float seed) 
{
	pos *= scale;
	float4 i = floor(pos).xyxy + float2(0.0, 1.0).xxyy;
	float2 f = pos - i.xy;
	i = mod(i, scale.xyxy);
	
	float4 hash = hash4D(i.xy + seed);
	if (hash.w > density)
		return 0.0;

	float radius = saturate(size + (hash.z * 2.0 - 1.0) * sizeVariation * 0.5);
	float value = radius / size;  
	radius = 2.0 / radius;
	f = f * radius - (radius - 1.0);
	f += hash.xy * (radius - 2.0);
	f = pow(abs(f), lerp(20.0, 1.0, sqrt(roundness)));

	float u = 1.0 - min(dot(f, f), 1.0);
	return float3(clamp(u * u * u * value, 0.0, 1.0), hash.w, hash.z);
}


// worley noises

float2 cellularNoise(float2 pos, float2 scale, float jitter, float phase, uint metric, float seed) 
{       
	pos *= scale;
	float2 i = floor(pos);
	float2 f = pos - i;
	
	const float3 offset = float3(-1.0, 0.0, 1.0);
	float4 cells = mod(i.xyxy + offset.xxzz, scale.xyxy) + seed;
	i = mod(i, scale) + seed;
	float4 dx0, dy0, dx1, dy1;
	multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
	multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);
	dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
	dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
	dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
	dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;
	
	dx0 = offset.xyzx + dx0 * jitter - f.xxxx; // -1 0 1 -1
	dy0 = offset.xxxy + dy0 * jitter - f.yyyy; // -1 -1 -1 0
	dx1 = offset.zzxy + dx1 * jitter - f.xxxx; // 1 1 -1 0
	dy1 = offset.zyzz + dy1 * jitter - f.yyyy; // 1 0 1 1
	float4 d0 = distanceMetric(dx0, dy0, metric);
	float4 d1 = distanceMetric(dx1, dy1, metric);
	
	float2 centerPos = (0.5 * sin(phase + kPI2 *  multiHash2D(i)) + 0.5) * jitter - f; // 0 0
	float4 F = min(d0, d1);
	// shuffle into F the 4 lowest values
	F = min(F, max(d0, d1).wzyx);
	// shuffle into F the 2 lowest values 
	F.xy = min(min(F.xy, F.zw), max(F.xy, F.zw).yx);
	// add the last value
	F.zw = float2(distanceMetric(centerPos, metric), 1e+5);
	// shuffle into F the final 2 lowest values 
	F.xy = min(min(F.xy, F.zw), max(F.xy, F.zw).yx);
	
	float2 f12 = float2(min(F.x, F.y), max(F.x, F.y));
	// normalize: 0.75^2 * 2.0  == 1.125
	return (metric == 0u ? sqrt(f12) : f12) * (1.0 / 1.125);
}
float3 cellularNoised(float2 pos, float2 scale, float jitter, float phase, float seed) 
{       
	pos *= scale;
	float2 i = floor(pos);
	float2 f = pos - i;
	
	const float3 offset = float3(-1.0, 0.0, 1.0);
	float4 cells = mod(i.xyxy + offset.xxzz, scale.xyxy) + seed;
	i = mod(i, scale) + seed;
	float4 dx0, dy0, dx1, dy1;
	multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
	multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);
	dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
	dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
	dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
	dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;
	
	dx0 = offset.xyzx + dx0 * jitter - f.xxxx; // -1 0 1 -1
	dy0 = offset.xxxy + dy0 * jitter - f.yyyy; // -1 -1 -1 0
	dx1 = offset.zzxy + dx1 * jitter - f.xxxx; // 1 1 -1 0
	dy1 = offset.zyzz + dy1 * jitter - f.yyyy; // 1 0 1 1
	float4 d0 = dx0 * dx0 + dy0 * dy0; 
	float4 d1 = dx1 * dx1 + dy1 * dy1; 
	
	float2 centerPos = (0.5 * sin(phase + kPI2 *  multiHash2D(i)) + 0.5) * jitter - f; // 0 0
	float dCenter = dot(centerPos, centerPos);
	float4 d = min(d0, d1);
	float4 less = step(d1, d0);
	float4 dx = lerp(dx0, dx1, less);
	float4 dy = lerp(dy0, dy1, less);

	float3 t1 = d.x < d.y ? float3(d.x, dx.x, dy.x) : float3(d.y, dx.y, dy.y);
	float3 t2 = d.z < d.w ? float3(d.z, dx.z, dy.z) : float3(d.w, dx.w, dy.w);
	t2 = t2.x < dCenter ? t2 : float3(dCenter, centerPos);
	float3 t = t1.x < t2.x ? t1 : t2;
	t.x = sqrt(t.x);
	// normalize: 0.75^2 * 2.0  == 1.125
	return  t * float3(1.0, -2.0, -2.0) * (1.0 / 1.125);
}

float3 voronoi(float2 pos, float2 scale, float jitter, float phase, float seed)
{
		// voronoi based on Inigo Quilez: https://archive.is/Ta7dm
	pos *= scale;
	float2 i = floor(pos);
	float2 f = pos - i;

	// first pass
	float2 minPos, tilePos;
	float minDistance = 1e+5;
	float2 n;
	for (n.y = -1.0; n.y <= 1.0; n.y++)
	{
		for (n.x = -1.0; n.x <= 1.0; n.x++)
		{
			float2 cPos = hash2D(mod(i + n, scale) + seed) * jitter;
			cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
			float2 rPos = n + cPos - f;

			float d = dot(rPos, rPos);
			if(d < minDistance)
			{
				minDistance = d;
				minPos = rPos;
				tilePos = cPos;
			}
		}
	}

	// second pass, distance to edges
	minDistance = 1e+5;
	for (n.y = -1.0; n.y <= 1.0; n.y++)
	{
		for (n.x = -1.0; n.x <= 1.0; n.x++)
		{
			float2 cPos = hash2D(mod(i + n, scale) + seed) * jitter;
			cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
			float2 rPos = n + cPos - f;
			
			float2 v = minPos - rPos;
			if(dot(v, v) > 1e-5)
				minDistance = min(minDistance, dot( 0.5 * (minPos + rPos), normalize(rPos - minPos)));
		}
	}

	return float3(minDistance, tilePos);
}
float3 cracks(float2 pos, float2 scale, float jitter, float width, float smoothness, float warp, float warpScale, bool warpSmudge, float smudgePhase, float seed)
{
	float3 g = gradientNoised(pos, scale * warpScale, smudgePhase, seed);
	pos += (warpSmudge ? g.yz : g.xx) * 0.1 * warp;
	float3 v = voronoi(pos, scale, jitter, 0.0, seed);
	return float3(smoothstep(max(width - smoothness, 0.0), width + fwidth(v.x), v.x), v.yz);
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, float seed) 
{       
	pos *= scale;
	float2 i = floor(pos);
	float2 f = pos - i;
	
	const float3 offset = float3(-1.0, 0.0, 1.0);
	float4 cells = mod(i.xyxy + offset.xxzz, scale.xyxy) + seed;
	i = mod(i, scale) + seed;
	float4 dx0, dy0, dx1, dy1;
	multiHash2D(float4(cells.xy, float2(i.x, cells.y)), float4(cells.zyx, i.y), dx0, dy0);
	multiHash2D(float4(cells.zwz, i.y), float4(cells.xw, float2(i.x, cells.w)), dx1, dy1);
	dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
	dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
	dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
	dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;
	
	dx0 = offset.xyzx + dx0 * jitter - f.xxxx; // -1 0 1 -1
	dy0 = offset.xxxy + dy0 * jitter - f.yyyy; // -1 -1 -1 0
	dx1 = offset.zzxy + dx1 * jitter - f.xxxx; // 1 1 -1 0
	dy1 = offset.zyzz + dy1 * jitter - f.yyyy; // 1 0 1 1
	float4 d0 = dx0 * dx0 + dy0 * dy0; 
	float4 d1 = dx1 * dx1 + dy1 * dy1; 
	
	float2 centerPos = (0.5 * sin(phase + kPI2 * multiHash2D(i)) + 0.5) * jitter - f; // 0 0
	
	float d = min(1.0, dot(centerPos, centerPos));
	d = min(d, d * d0.x);
	d = min(d, d * d0.y);
	d = min(d, d * d0.z);
	d = min(d, d * d0.w);
	d = min(d, d * d1.x);
	d = min(d, d * d1.y);
	d = min(d, d * d1.z);
	d = min(d, d * d1.w);
	
	return sqrt(d);
}

float metaballs(float2 pos, float2 scale, float jitter, float phase, float width, float smoothness, float seed) 
{       
	float d = metaballs(pos, scale, jitter, phase, seed);
	return smoothstep(width, width + smoothness, d);
}

// fbms

float fbm(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float octaveFactor, float seed) 
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2x2 rotate = Rotation2D(shift);

	float value = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float n = noise(p / frequency, frequency, time, seed);
		value += amplitude * n;
		
		p = p * lacunarity + offset * float(1 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(rotate, offset);
	}
	return value * 0.5 + 0.5;
}

float3 fbmd(float2 pos, float2 scale, int octaves, float2 shift, float timeShift, float gain, float2 lacunarity, float slopeness, float octaveFactor, float seed) 
{
	// fbm implementation based on Inigo Quilez
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;
	
	float2 sinCos = float2(sin(shift.x), cos(shift.y));
	float2x2 rotate = float2x2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

	float3 value = 0.0;
	float2 derivative = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float3 n =  noised(p / frequency, frequency, time, seed).xyz;
		derivative += n.yz;

		n *= amplitude;
		n.x /= (1.0 + lerp(0.0, dot(derivative, derivative), slopeness));
		value += n; 
		
		p = (p + shift) * lacunarity;
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		shift = mul(shift, rotate);
		time += timeShift;
	}
	
	value.x = value.x * 0.5 + 0.5;
	return value;
}
/*float3 fbmd(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float slopeness, float octaveFactor, float seed) 
{
	return fbmd(pos, scale, octaves, shift, timeShift, gain, lacunarity, slopeness, octaveFactor, seed);
}
float3 fbmd(float2 pos, float2 scale, int octaves, float2 shift, float timeShift, float gain, float lacunarity, float slopeness, float octaveFactor, float seed) 
{
	return fbmd(pos, scale, octaves, shift, timeShift, gain, lacunarity, slopeness, octaveFactor, seed);
}*/

float fbmMetaballs(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float octaveFactor, float jitter, float interpolate, float2 width, float seed) 
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2x2 rotate = Rotation2D(shift);
	
	float n = 1.0;
	float value = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float cn = metaballs(p / frequency, frequency, jitter, timeShift, width.x, width.y, seed) * 2.0 - 1.0;
		n *= cn;
		value += amplitude * lerp(n, abs(n), interpolate);
		
		p = p * lacunarity + offset * float(1 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(rotate, offset);
	}
	return value * 0.5 + 0.5;
}

float fbmPerlin(float2 pos, float2 scale, int octaves, float shift, float axialShift, float gain, float lacunarity, uint mode, float factor, float offset, float seed) 
{
	float amplitude = gain;
	float2 frequency = floor(scale);
	float angle = axialShift;
	float n = 1.0;
	float2 p = frac(pos) * frequency;

	float value = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float pn = perlinNoise(p / frequency, frequency, angle, seed) + offset;
		if (mode == 0u)
		{
			n *= abs(pn);
		}
		else if (mode == 1u)
		{
			n = abs(pn);
		}
		else if (mode == 2u)
		{
			n = pn;
		}
		else if (mode == 3u)
		{
			n *= pn;
		}
		else if (mode == 4u)
		{
			n = pn * 0.5 + 0.5;
		}
		else
		{
			n *= pn * 0.5 + 0.5;
		}
		
		n = pow(n < 0.0 ? 0.0 : n, factor);
		value += amplitude * n;
		
		p = p * lacunarity + shift;
		frequency *= lacunarity;
		amplitude *= gain;
		angle += axialShift;
	}
	return value;
}

float3 fbmdPerlin(float2 pos, float2 scale, int octaves, float2 shift, float2x2 transform, float gain, float2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed) 
{
	// fbm implementation based on Inigo Quilez
	float amplitude = gain;
	float2 frequency = floor(scale);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.3;

	float3 value = 0.0;
	float2 derivative = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float3 n = perlinNoised(p / frequency, frequency, transform, seed);
		derivative += n.yz;
		n.x = negative ? n.x : n.x * 0.5 + 0.5;
		n *= amplitude;
		value.x += n.x / (1.0 + lerp(0.0, dot(derivative, derivative), slopeness));
		value.yz += n.yz; 
		
		p = (p + shift) * lacunarity;
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		transform = mul(transform, transform);
	}

	return clamp(value,-1.,1.);
}
float3 fbmdPerlin(float2 pos, float2 scale, int octaves, float2 shift, float axialShift, float gain, float2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed) 
{
	float2x2 transform = mul(float2x2(0.8, -0.6, 0.6, 0.8), Rotation2D(axialShift));
	return fbmdPerlin(pos, scale, octaves, shift, transform, gain, lacunarity, slopeness, octaveFactor, negative, seed);
}

float4 fbmVoronoi(float2 pos, float2 scale, int octaves, float shift, float timeShift, float gain, float lacunarity, float octaveFactor, float jitter, float interpolate, float seed) 
{
	float amplitude = gain;
	float time = timeShift;
	float2 frequency = scale;
	float2 offset = float2(shift, 0.0);
	float2 p = pos * frequency;
	octaveFactor = 1.0 + octaveFactor * 0.12;

	float2x2 rotate = Rotation2D(shift);
	
	float n = 1.0;
	float4 value = 0.0;
	for (int i = 0; i < octaves; i++) 
	{
		float3 v = voronoi(p / frequency, frequency, jitter, timeShift, seed);
		v.x = v.x * 2.0 - 1.0;
		n *= v.x;
		value += amplitude * float4(lerp(v.x, n, interpolate), hash3D(v.yz));
		
		p = p * lacunarity + offset * float(1 + i);
		frequency *= lacunarity;
		amplitude = pow(amplitude * gain, octaveFactor);
		time += timeShift;
		offset = mul(rotate, offset);
	}
	value.x = value.x * 0.5 + 0.5;
	return value;
}


// warp

float fbmWarp(float2 pos, float2 scale, float2 factors, int octaves, float4 shifts, float timeShift, float gain, float2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed,
				out float2 q, out float2 r) 
{
	// domain warping with factal sum value noise

	float qfactor = factors.x;
	float rfactor = factors.y;
	q.x = fbmd(pos, scale, octaves, 0.0, timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
	q.y = fbmd(pos, scale, octaves, shifts.x, timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
	q = negative ? q * 2.0 - 1.0 : q;
	
	float2 np = pos + qfactor * q;
	r.x = fbmd(np, scale, octaves, shifts.y, timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
	r.y = fbmd(np, scale, octaves, shifts.z, timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
	r = negative ? r * 2.0 - 1.0 : r;
	
	return fbmd(pos + r * rfactor, scale, octaves, shifts.w, timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
}

float perlinNoiseWarp(float2 pos, float2 scale, float strength, float phase, float factor, float spread, float seed)
{
	float2 offset = float2(spread, 0.0);
	strength *= 32.0 / max(scale.x, scale.y);
	
	float4 gp;
	gp.x = perlinNoise(pos - offset.xy, scale, phase, seed);
	gp.y = perlinNoise(pos + offset.xy, scale, phase, seed);
	gp.z = perlinNoise(pos - offset.yx, scale, phase, seed);
	gp.w = perlinNoise(pos + offset.yx, scale, phase, seed);
	gp = pow(gp, factor);
	float2 warp = float2(gp.y - gp.x, gp.w - gp.z);
	return pow(perlinNoise(pos + warp * strength, scale, phase, seed), factor);
}

float curlWarp(float2 pos, float2 scale, float2 factors, float4 seeds, float curl, float seed,
				out float2 q, out float2 r)
{
	float qfactor = factors.x;
	float rfactor = factors.y;
	float2 curlFactor = float2(1.0, -1.0) * float2(curl, 1.0 - curl);
	
	float2 n = gradientNoised(pos, scale, seed).zy * curlFactor;
	q.x = n.x + n.y;
	n = gradientNoised(pos + hash2D(seeds.xx), scale, seed).zy * curlFactor;
	q.y = n.x + n.y;
	
	float2 np = pos + qfactor * q;
	n = gradientNoised(np + hash2D(seeds.yy), scale, seed).zy * curlFactor;
	r.x = n.x + n.y;
	n = gradientNoised(np + hash2D(seeds.zz), scale, seed).zy * curlFactor;
	r.y = n.x + n.y;

	return perlinNoise(pos + r * rfactor + hash2D(seeds.ww), scale, seed);
}

// other

float sdfLens(float2 p, float width, float height)
{
	float d = 1.0 / width - width / 4.0;
	float r = width / 2.0 + d;
	
	p = abs(p);

	float b = sqrt(r * r - d * d);
	float4 par = p.xyxy - float4(0.0, b, -d, 0.0);
	return (par.y * d > p.x * b) ? length(par.xy) : length(par.zw) - r;
}
float3 tileWeave(float2 pos, float2 scale, float count, float width, float smoothness)
{
	float2 i = floor(pos * scale);    
	float c = mod(i.x + i.y, 2.0);
	
	float2 p = frac(pos * scale);
	p = lerp(p, p.yx, c);
	p = frac(p * float2(count, 1.0));
	
	// Vesica SDF based on Inigo Quilez
	width *= 2.0;
	p = p * 2.0 - 1.0;
	float d = sdfLens(p, width, 1.0);
	float2 grad = float2(ddx(d), ddy(d));

	float s = 1.0 - smoothstep(0.0, dot(abs(grad), 1.0) + smoothness, -d);
	return float3(s , normalize(grad) * smoothstep(1.0, 0.99, s) * smoothstep(0.0, 0.01, s)); 
}

float3 checkers45(const in float2 pos, const in float2 scale, const in float2 smoothness)
{
	// based on filtering the checkerboard by Inigo Quilez 
	float2 numTiles = floor(scale); 
	float2 p = pos * numTiles * 2.0;

	p *= 1.0 / sqrt(2.0);
	p = mul(Rotation2D(radians(45)), p);
	p += float2(0.5, 0.0);
	float2 tile = mod(floor(p), numTiles);
	
	float2 w = smoothness;
	// box filter using triangular signal
	float2 s1 = abs(frac((p - 0.5 * w) / 2.0) - 0.5);
	float2 s2 = abs(frac((p + 0.5 * w) / 2.0) - 0.5);
	float2 i = 2.0 * (s1 - s2) / w;
	float d = 0.5 - 0.5 * i.x * i.y; // xor pattern
	return float3(d, tile);
}