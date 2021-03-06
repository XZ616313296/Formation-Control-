%% Formation Control + Obstacle Advoidance using APF and RVF, Ting-Yang(Gordon) Chen, University of Washington, June 2018
%formation control and non-collision strategy using APF and RVF
%This method prevents agents from trapping at an undesired euilibrium (saddle point),
%which might be created that if the initial and desired positions of agents R1 and R2 are on the same straight line.
%The agents might mutually cancel their motion as they move to their opposite side. 
%The vortex generated by RVF's can prevent the agents from trapping at undesired equilibrium
clear all;close all;clc;

global eta d dt iteration numNodes z0 kd

%plot the directed graph
G = digraph([1 2 2 3 3],[2 1 3 1 4]); 

figure(1)
plot(G)
title('Formation Graph D(G)')


numNodes = 4; %number of agents

eta =10; %gain of RPF

kd = 1;% gain of APF

d =6 ; % The distance whcih robots will be in danger of collision (activated zone)

dt=0.01;%sampling period

iteration =599;%numbers of iterations 

z0 = [ 0 -1, -1 0, -4 -1, 1 -3]';%initial position

%initialize the array for the state of agents
%z = [z1x(0) z1x(k) ...
%       z1y(0) z1y(k) ......
%       .
%       .
%       z8y(0) z8y(k)]
%size(z) = [numNodes*2, k]
z = zeros(numNodes*2, iteration+1);

%desired relative position
c21 = [-5 0];
c12 = [5 0];
c31 = [-5 5];
c23 = [0 -5];
c34 = [-5 0];

%desired vectors of relative positions (c_mat = [sum of the desired vectors of positions for x1, y1, x2, y2, x3, y3, x4, y4])
c_mat = [c21(1,1)+c31(1,1), c21(1,2)+c31(1,2), c12(1,1), c12(1,2), c23(1,1), c23(1,2), c34(1,1), c34(1,2)]';

%initialize the array for the repulsive potential function
v = zeros(numNodes,numNodes,length(z));
dis = zeros(numNodes,numNodes,length(z));

z(:,1)=z0;

for k = 1:iteration
    
    dis(1,2,k) = norm(z(1:2,k) - z(3:4,k)); %distance between node 1 and node 2
    dis(1,3,k) = norm(z(1:2,k) - z(5:6,k)); %distance between node 1 and node 3
    dis(1,4,k) = norm(z(1:2,k) - z(7:8,k)); %distance between node 1 and node 4
    dis(2,1,k) = dis(1,2,k);                    %distance between node 2 and node 1 (same as dis21)
    dis(2,3,k) = norm(z(3:4,k) - z(5:6,k)); %distance between node 2 and node 3
    dis(2,4,k) = norm(z(3:4,k) - z(7:8,k)); %distance between node 2 and node 4
    dis(3,1,k) = dis(1,3,k);                    %distance between node 3 and node 1
    dis(3,2,k) = dis(2,3,k);                    %distance between node 3 and node 2
    dis(3,4,k) = norm(z(5:6,k) - z(7:8,k)); %distance between node 3 and node 4
    dis(4,1,k) = dis(1,4,k);                    %distance between node 4 and node 1
    dis(4,2,k) = dis(2,4,k);                    %distance between node 4 and node 2
    dis(4,3,k) = dis(3,4,k);                    %distance between node 4 and node 3
    
    
    for i = 1:numNodes %store each RVF value into the RVF array 
        for j = 1:numNodes
            if j ~= i
                dev = (dis(i,j,k))^2 - d^2 <= 0;
                v(i,j,k) = eta*dev*((dis(i,j,k)^-2) - (d^-2))^2;
            else
                v(i,j,k) = 0;
            end
        end
    end
    
    for i = 1:numNodes % x(i)
        for j = 1: numNodes %x(j)
            
            shi(2*i-1:2*i ,j, k) = v(i,j,k).*...
                [ ( z(2*i-1, k) - z(2*j-1,k)) - ( z(2*i, k) - z(2*j, k) );
                ( z(2*i-1, k) - z(2*j-1,k)) + ( z(2*i, k) - z(2*j, k) )];            
        end
    end
    
    z(1,k+1) = z(1,k) + ( shi(1,2,k) +shi(1,3,k) + shi(1,4,k) )*dt...
        - kd*(( (z(1,k) - z(3,k)) + (z(1,k) - z(5,k)) ) - c_mat(1,1) )*dt;
    
    z(2,k+1) = z(2,k) + ( shi(2,2,k) +shi(2,3,k) + shi(2,4,k) )*dt...
        - kd*(( (z(2,k) - z(4,k)) + (z(2,k) - z(6,k)) ) - c_mat(2,1) )*dt;
    
    z(3,k+1) = z(3,k) + ( shi(3,1,k) +shi(3,3,k) + shi(3,4,k) )*dt...
        - kd*( z(3,k) - z(1,k) - c_mat(3,1) )*dt;
    
    z(4,k+1) = z(4,k) + ( shi(4,1,k) +shi(4,3,k) + shi(4,4,k) )*dt...
        - kd*( z(4,k) - z(2,k) - c_mat(4,1) )*dt;
    
    z(5,k+1) = z(5,k) + ( shi(5,1,k) +shi(5,2,k) + shi(5,4,k) )*dt...
        - kd*( z(5,k) - z(3,k) - c_mat(5,1) )*dt;
    
    z(6,k+1) = z(6,k) + ( shi(6,1,k) +shi(6,2,k) + shi(6,4,k) )*dt...
        - kd*( z(6,k) - z(4,k) - c_mat(6,1) )*dt;
    
    z(7,k+1) = z(7,k) + ( shi(7,1,k) +shi(7,2,k) + shi(7,3,k) )*dt...
        - kd*( z(7,k) - z(5,k) - c_mat(7,1) )*dt;
    
    z(8,k+1) = z(8,k) + (shi(8,1,k) +shi(8,2,k) + shi(8,3,k) )*dt...
        - kd*( z(8,k) - z(6,k) - c_mat(8,1) )*dt;
    
end

figure(2)
plot(z(1,1),z(2,1),'ro',z(3,1),z(4,1),'bo',z(5,1),z(6,1),'go',z(7,1),z(8,1),'ko')
hold on
for i=2:iteration
    axis([-8 4 -8 4]);
    plot(z(1,i),z(2,i),'r:.')
    hold on
    plot(z(3,i),z(4,i),'b:.')
    hold on
    plot(z(5,i),z(6,i),'g:.')
    hold on
    plot(z(7,i),z(8,i),'k:.')
    hold on
    title('Formation Control and Collision Advoidance using APF and RVF (Digraph) (o=start, x=end)')
    grid on
    xlabel('x')
    ylabel('y')
    drawnow
end
plot(z(1,iteration+1), z(2,iteration+1),'xr',z(3,iteration+1), z(4,iteration+1),'xb',...
    z(5,iteration+1), z(6,iteration+1),'xg',z(7,iteration+1), z(8,iteration+1),'xk')
grid on
legend('Agent1','Agent2','Agent3','Agent4')