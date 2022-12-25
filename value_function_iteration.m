
clear all
close all
clc

% 1.(a) calculate k*
% using Euler's equation to solve steady_k, we can get steady_k = ((β^(-1)-1+δ)/σA)^(1/(σ-1))
bbeta    = 0.96;
ddelta   = 0.069;  
ssigma   = 2;  
aalpha = 0.36;
A = 1;
steady_k = ((bbeta^(-1)-1+ddelta)/(aalpha*A))^(1/(aalpha-1));



% 1.(b) create Kgrid
w_min    = 0.1*steady_k;  % Min ration stock.
w_bar    = 2*steady_k;   % Max ration stock.
ngrid    = 1000;  % The number of grid points.
Kgrid    = linspace(w_min, w_bar, ngrid);

% 1.(c) create IKMAX

IKMAX = linspace(1, 1000, 1000);
% update IKMAX
for i =1:1000
    for j = 1000:-1:1
        if Kgrid(j) < A * Kgrid(i)^aalpha +(1-ddelta)*Kgrid(i)
            IKMAX(i) = j;
            break
        end
    end
    
end

%{
1.(c) V0 is defined in the buttom of this code
function V0 = V_0(~)
   V0 = 0;
end
%}


policy  = linspace(1, 1000, 1000);
%disp(V_0(IKMAX(1)));
% 1.(d) cumpute Tv
TV = linspace(1, 1000, 1000);
for i = 1:1000
   tempVal = -10000;
   for j = 1:IKMAX(i)
       if ((((Kgrid(i)^aalpha) + (1-ddelta)*Kgrid(i)-Kgrid(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(Kgrid(j)))>tempVal
           tempVal =(((Kgrid(i)^aalpha) + (1-ddelta)*Kgrid(i)-Kgrid(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(Kgrid(j));
           thisPolicy = Kgrid(j);
       end
   end
   TV(i) = tempVal;
   policy(i) = thisPolicy;
end
%disp(TV)

% 1.(e) calculate err
for i = 1:1000
    temp = 0;
    if abs(TV(i)-V_0()) > temp
        temp = abs(TV(i)-V_0());
    end
end

err_0 = temp;
%disp(err_0);

% Set tolerance
tol_err  = 1e-6;
tol_iter = 1000;
% Create counterspolicy
n_iter = 1;
err    = tol_err + 1;

% % 1.(e) cumpute Tv
tic
while n_iter < tol_iter && err > tol_err
    TV_temp = TV;
    for i = 1:1000
        tempVal = 0;
        for j = 1:IKMAX(i)
            thisTV_i = (((Kgrid(i)^aalpha) + (1-ddelta)*Kgrid(i)-Kgrid(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*TV_temp(j);
            if thisTV_i >tempVal
                tempVal = thisTV_i;
                thisPolicy = Kgrid(j);
            end
        end
        TV(i) = tempVal;
        policy(i) = thisPolicy; 
    end
    % calculate err
    for i = 1:1000
        temp = 0;
        if abs(TV(i)-TV_temp(i)) > temp
            temp = abs(TV(i)-TV_temp(i));
        end
    end
    err = temp;
    n_iter = n_iter + 1;
    if mod(n_iter, 25) == 0
        disp(['Error at iteration ', num2str(n_iter), ...
            ' is ', num2str(err), '.'])
    end
end
toc

% Plot the value function and the policy function

f = figure();
tiledlayout(1, 2);


% Plot value function
nexttile
plot(Kgrid, TV, 'LineWidth', 2.5)
hold on
xlabel('K')
ylabel('V')
title('Value Function')
legend({'V'}, ...
    'Location', 'southeast')

% Plot policy function
nexttile
plot(Kgrid, policy, 'LineWidth', 2.5);
hold on
xlabel('K')
ylabel("policy")
title('Policy Function')
legend({'Policy'}, ...
    'Location', 'southeast')

function V0 = V_0(~)
   V0 = 0;
end
%{
The following are some attemp to calculate TV, but they are redudent. 
function V1 = valunFunction1(i,Kgrid,IKMAX,V_0)
   tempVal = 0;
   bbeta    = 0.96;
   ddelta   = 0.069;  
   ssigma   = 2;  
   aalpha = 0.36;
   for j = 1:i
       if ((((Kgrid(j)^aalpha) + (1-ddelta)*Kgrid(i)-IKMAX(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(IKMAX(j)))>tempVal
           tempVal =(((Kgrid(j)^aalpha) + (1-ddelta)*Kgrid(i)-IKMAX(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(IKMAX(j));
       end
   end
   V1 = tempVal;
end


function V = valunFunction(i,Kgrid,V_0)
   tempVal = 0;
   bbeta    = 0.96;
   ddelta   = 0.069;  
   ssigma   = 2;  
   aalpha = 0.36;
   for j = 1:1000
       if ((((Kgrid(j)^aalpha) + (1-ddelta)*Kgrid(i)-Kgrid(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(Kgrid(j)))>tempVal
           tempVal =(((Kgrid(j)^aalpha) + (1-ddelta)*Kgrid(i)-Kgrid(j))^(1-ssigma)-1)/(1-ssigma) +bbeta*V_0(Kgrid(j));
       end
   end
   V = tempVal;
end
%}
%function err_0 = calculateError0(Kgrid,valunFunction1,V_0)
%    temp = 0;
%    for i = 1:1000   
%        if abs(valunFunction1(i,Kgrid)-V_0()) > temp
%            temp = abs(valunFunction1(i,Kgrid)-V_0());
%        end
%    end
%    err_0 = temp;
%end



