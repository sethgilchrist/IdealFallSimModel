function [displacementRate,loadingRate] = stiffVsRatesData(kFemur,bFemur)
% This function takes a vector of femoral stiffnesses (length = s) and a 
% vector of femoral damping values (length = d) as inputs and returns two
% d by s matricies of displacement and loading rates. Each row corresponds
% to a damping value and each column to a stiffness value.

% define stiffnesses
kPlevis = 50000; %N/m

% preallocate
displacementRate = zeros(length(bFemur),length(kFemur));
loadingRate = zeros(size(displacementRate));

% solve the ode
for i = 1:size(displacementRate,1)
    for j = 1:size(displacementRate,2)
        % get the time and displacement values from the ODE solver
        [t,x] = displacementSimple(kFemur(j),kPlevis,bFemur(i));
        % find the first time that the compression and damping are greater
        % than 1500 N
        cIndex = find(x(:,3)*kFemur(j)+x(:,4)*bFemur(i) > 1500,1,'first')-1;
        % calculate the displacement rate
        displacementRate(i,j) = x(cIndex,3)/t(cIndex);
        % calculate the loading rate based on the average displacement rate
        % for the velocity of the compression
        loadingRate(i,j) = (x(cIndex,3)*kFemur(j) + bFemur(i)*displacementRate(i,j))/t(cIndex);
    end
end
end


function [t,x] = displacementSimple(kf,ks,bf)
% A simple model of the fall simulator consisting of two masses, two
% springs and one damper.
% Usage
% [t,x] = displacementSimple(femurStiffness,springStiffness,femurDamping)
%
% t = vector of time
% x(1) = displacement of top of spring
% x(2) = velocity of top of spring
% x(3) = displacement of trochanter
% x(4) = velocity of trochanter

springMass = 3.5; %kg

M1 = springMass/3 + 1 + 32; % kg: top 1/3 spring + top plate + body mass
M2 = springMass/3 + 10 + 1.98; %kg: bottom 1/3 spring + bottom plate + stabalizer + loadcell + loader +  falling mass

initialConditions = [0,2.9,0,0];

[t,x] = ode45(@(t,x) system(t,x,M1,M2,kf,ks,bf),linspace(0,0.05,5000),initialConditions);
end

function dxdt = system(t,x,M1,M2,Kf,Ks,Bf)
if t < 0.005
    f2pulse = 0;%250*sin(2*pi/.01*t); % repace this line with "f2pulse = 0" to omit the force pulse on mass 2
else
    f2pulse = 0;
end

xM1 = x(1);
xM1dot = x(2);
xM2 = x(3);
xM2dot = x(4);

dxdt = zeros(size(x));
dxdt(1) = xM1dot;
dxdt(2) = 1/M1 * (9.81*M1 + (xM2-xM1)*Ks);
dxdt(3) = xM2dot;
dxdt(4) = 1/M2 * (9.81*M2 + f2pulse - xM2*Kf - (xM2-xM1)*Ks - xM2dot*Bf);
end